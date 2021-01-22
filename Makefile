
yamllint:
	@yamllint --version
	@yamllint --strict .

lint-all: yamllint
