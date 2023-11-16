import logging
import sys
import os
import ansible_runner
from pathlib import Path

logging.basicConfig(
    format="[stackify] 📚 %(message)s",
    stream=sys.stdout,
    level=logging.INFO,
)

class Stackify():
    _log: logging.Logger = logging.getLogger("stackify")

    def __init__(self) -> None:
        self.log.debug("initializing")
        self.path = Path(__file__).resolve().parent.joinpath("ansible")

    @property
    def log(self) -> logging.Logger:
        return self._log

    def run(self) -> None:
        self.log.info("running")
        self.log.info("path={path}".format(path=self.path))
        r = ansible_runner.run(private_data_dir=self.path, playbook='main.yml')
        self.log.info("status={status}: exit_code={exit_code}".format(status=r.status, exit_code=r.rc))
        self.log.info("final status {stats}".format(stats=r.stats))
