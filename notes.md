## Olama

### Make my AMD RX 6700 XT work for Ollama

Add this to the systemd service file:

Environment="HSA_OVERRIDE_GFX_VERSION=10.3.0"

see: https://news.ycombinator.com/item?id=39719695

> mey 8 months ago | parent | next [–]
>
> Sad to see that the cut off is just after 6700 XT which is what is in my desktop. They indicate more devices are coming, hopefully that includes some of the more modern all in one chips with RDNA 2/3 from AMD as well.
>
> mey 8 months ago | parent | next [–]
>
>     It appears that the cut off lines up with HIP SDK support from AMD, https://rocm.docs.amd.com/projects/install-on-windows/en/lat...
>
>         bavell 8 months ago | parent | prev | next [–]
>
>         I've been using my 6750XT for more than a year now on all sorts of AI projects. Takes a little research and a few env vars but no need to wait for "official" support most of the time.
>
>         throawayonthe 8 months ago | parent | prev [–]
>
>         I’ve already been using ollama with my 6700xt just fine, you just have to set some env variable to make rocm work “unoficially”
>
>         The linked page says they will support more soon, so i’m guessing this will just be integrated
>
>             Rising6378 8 months ago | root | parent [–]
>
>             which env variable did you set to what? currently I'm struggeling setting it up
>
>                 Retr0id 8 months ago | root | parent [–]
>
>                 HSA_OVERRIDE_GFX_VERSION=10.3.0 seems to be the magic words.
>
>                 You can invoke it directly via `HSA_OVERRIDE_GFX_VERSION=10.3.0 ollama serve`, but I added this line to the systemd unit at /etc/systemd/system/ollama.service:
>
>                     Environment="HSA_OVERRIDE_GFX_VERSION=10.3.0"
