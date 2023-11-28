# Soket

With two terminals open run 

```
# left
systemd-socket-activate -l 8888 --fdname=tcp -E ERL_FLAGS='-kernel inet_backend socket' mix phx.server

# right
nc localhost 8888
```

The `inet_backend` option doesn't seem to be making a difference. Both should work nowadays though.

## Context

- https://github.com/erlang/otp/issues/4680
- https://github.com/mtrudel/bandit/issues/130
- https://github.com/hauleth/erlang-systemd/blob/master/examples/plug/lib/plug_systemd_example/application.ex