-- Synced from barnabasJ/edb, commit 2b136d5, integrations/neovim/edb.lua.
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
local states = setmetatable({}, { __mode = "k" })
local steps = { next = true, stepIn = true, stepOut = true }
local execution = { next = true, stepIn = true, stepOut = true, continue = true, disconnect = true }

local function invalidate(session)
	local state = states[session]
	if state then
		state.generation = state.generation + 1
	end
end

local function recover(session, state, generation, thread_id, err)
	if not err or session.closed or session.stopped_thread_id or state.generation ~= generation then
		return
	end
	session:request("stackTrace", { threadId = thread_id }, function(stack_err, response)
		if
			stack_err
			or not response
			or not response.stackFrames
			or #response.stackFrames == 0
			or session.closed
			or session.stopped_thread_id
			or state.generation ~= generation
		then
			return
		end
		-- EDB only returns a stack for a paused process. Re-enter nvim-dap's
		-- normal stopped handler to restore thread state, source sign and scopes.
		session:event_stopped({ reason = "pause", threadId = thread_id, allThreadsStopped = true })
	end)
end

local function install(session)
	if not session or session.config.type ~= "edb" or states[session] then
		return
	end
	local state = { generation = 0 }
	states[session] = state
	local request = session.request
	-- Command listeners run when responses arrive. Wrap dispatch so an old
	-- failure or stack response cannot undo a newer execution command.
	session.request = function(self, command, arguments, callback)
		if execution[command] then
			invalidate(self)
		end
		if steps[command] and callback and arguments and arguments.threadId then
			local generation, thread_id = state.generation, arguments.threadId
			return request(self, command, arguments, function(err, response, seq)
				callback(err, response, seq)
				recover(self, state, generation, thread_id, err)
			end)
		end
		return request(self, command, arguments, callback)
	end
end

function M.setup(dap)
	dap = dap or require("dap")
	for _, event in ipairs({ "event_stopped", "event_continued", "event_terminated" }) do
		dap.listeners.before[event].edb_step_recovery = invalidate
	end
	dap.listeners.before.event_initialized.edb_step_recovery = install
	dap.listeners.on_session.edb_step_recovery = function(_, session)
		install(session)
	end
	for _, session in pairs(dap.sessions()) do
		install(session)
	end
end

return M
