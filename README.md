# ffplayout-updater

Simple script to update [ffplayout](https://github.com/ffplayout/ffplayout) output with now playing info.

<img width="502" alt="ffplayout-updater-example" src="https://github.com/user-attachments/assets/4bf56ef3-f4ff-478f-b754-20e39d01db91">

```
 Usage:
 update.sh [command] [api-token] <jsonrpc-host> <jsonrpc-port> <media-regex>
```

This script will publish a text message to your ffplayout's stream via a JSONRPC call. To obtain a token, check the FFPlayout config screen and enable the JSONRPC server

Depending on your media's source path, you will need to modify the `<media-regex>` to extract suitable metadata to display the media's title.

For now, you will need to modify the script directly for certain attributes like font size, color, etc.

## Commands

### `update_info`

Updates media info on the screen from `current` and `next`, font attributes are hard-coded in the script.

## Todo

- [ ] Figure out if RPC can take a dynamic font
- [ ] Display text periodically / on schedule
- [ ] Include systemd units to install on server
