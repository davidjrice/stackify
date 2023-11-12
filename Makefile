brew.build:
	@docker-compose build brew

brew.run:
	@docker-compose run --rm brew

debian.build:
	@docker-compose build debian

debian.run: debian.build
	@docker-compose run --rm debian

ubuntu.build:
	@docker-compose build ubuntu

ubuntu.run: ubuntu.build
	@docker-compose run --rm ubuntu