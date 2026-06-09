# SPDX-License-Identifier: MIT

import socket
import os
import logging


class Notifier:
    def __init__(self):
        self.socket = socket.socket(family=socket.AF_UNIX, type=socket.SOCK_DGRAM)
        address = os.getenv("NOTIFY_SOCKET")
        if not address:
            raise Exception("NOTIFY_SOCKET is not set")
        self.address = address
        logging.debug(f"Notify socket: {self.address}")

    def _send(self, msg: str):
        """Send `msg` as bytes on the socket"""
        self.socket.sendto(msg.encode(), self.address)

    def ready(self):
        """Service startup is finished"""
        self._send("READY=1\n")
