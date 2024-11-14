## Olama

### Make my AMD RX 6700 XT work for Ollama

Add this to the systemd service file:

Environment="HSA_OVERRIDE_GFX_VERSION=10.3.0"

see: https://news.ycombinator.com/item?id=39719695
