# Adhan-Sonos
This Bash script will install salat times as a crontab and plays adhan on your Sonos speakers on given times. 

# Required Software
- SONOS HTTP API (https://github.com/jishi/node-sonos-http-api).
- jq (script will install jq automatically if it is not installed).

# Optional Software
- Pushover.net for notifications.

# Features
- Plays static or random adhan.
- Customizable spoken preannouncement before adhan (can be turned off).
- Has day and night mode for volume.
- Day and night mode time are customizable.
- Day and night volume are customizable.
- Notifications when: 
  - Salat times are installed,
  - When it is time for salat.
- Notficiations can be turned off.
