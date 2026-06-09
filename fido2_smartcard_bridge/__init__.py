# SPDX-License-Identifier: MIT

import asyncio
import logging
import os

from .ctap_hid_device import CTAPHIDDevice
from .sd_notify import Notifier


async def run() -> None:
    """Asynchronously run the event loop."""
    device = CTAPHIDDevice()
    try:
        Notifier().ready()
    except Exception:
        logging.debug("Running outside a systemd service.")
    await device.start()


def main():
    logging.basicConfig(
        format="%(message)s",
        level=os.getenv("LOG_LEVEL", "INFO").upper(),
    )
    # Downgrade logging for the uhid device
    logging.getLogger("UHIDDevice").setLevel(logging.WARNING)

    loop = asyncio.new_event_loop()
    asyncio.set_event_loop(loop)
    loop.run_until_complete(run())
    loop.run_forever()
