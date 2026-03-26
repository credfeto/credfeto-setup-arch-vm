---
description: 'Guidance for updaing.'
applyTo: '**'
---

# Updating Guidelines

Use the arch linux instructions as basic guidance.

Keep all changes in the 'install' script unless explicitly specified in the request.

Make the install script run in such a way that it can be run many times without breaking or introducing duplicate configuration or unwanted configuration... 

e.g. if making a change to say /etc/pacman.conf then it should not make the change if it is already present.
