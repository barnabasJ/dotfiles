-- Synced from barnabasJ/edb, commit 9565bde, integrations/neovim/edb.lua.
-- SPDX-License-Identifier: Apache-2.0
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     https://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
-- nvim-dap clears its stopped thread before sending a step request. EDB can
-- reject that request without resuming (e.g. missing beam_debug_info).
-- Confirm the process is still paused and restore its frame after the error.
local M = {}

function M.setup(dap)
	dap = dap or require("dap")
	local generations = setmetatable({}, { __mode = "k" })
	local function invalidate(session)
		generations[session] = (generations[session] or 0) + 1
	end
	for _, event in ipairs({ "event_stopped", "event_continued", "event_terminated" }) do
		dap.listeners.before[event].edb_step_recovery = invalidate
	end
	for _, command in ipairs({ "next", "stepIn", "stepOut", "continue", "disconnect" }) do
		dap.listeners.before[command].edb_step_recovery = invalidate
	end
	for _, command in ipairs({ "next", "stepIn", "stepOut" }) do
		dap.listeners.after[command].edb_step_recovery = function(session, err, _, arguments)
			if
				not err
				or session.config.type ~= "edb"
				or session.closed
				or session.stopped_thread_id
				or not arguments
				or not arguments.threadId
			then
				return
			end
			local generation = generations[session]
			local thread_id = arguments.threadId
			session:request("stackTrace", { threadId = thread_id }, function(stack_err, response)
				if
					stack_err
					or not response
					or not response.stackFrames
					or #response.stackFrames == 0
					or session.closed
					or session.stopped_thread_id
					or generations[session] ~= generation
				then
					return
				end
				-- EDB only returns a stack for a paused process. Re-enter nvim-dap's
				-- normal stopped handler to restore thread state, source sign and scopes.
				session:event_stopped({
					reason = "pause",
					threadId = thread_id,
					allThreadsStopped = true,
				})
			end)
		end
	end
end

return M
