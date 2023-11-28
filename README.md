# Soket

With two terminals open run 

```
# left
systemd-socket-activate -l 8888 --fdname=tcp -E ERL_FLAGS='-kernel inet_backend socket' mix phx.server

# right
nc localhost 8888
```

The `inet_backend` option doesn't seem to be making a difference. Both should work nowadays though.