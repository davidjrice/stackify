from .stackify import Stackify


def cli() -> None:
    stackify = Stackify()
    stackify.run()


def main() -> None:
    cli()


if __name__ == "__main__":
    main()
