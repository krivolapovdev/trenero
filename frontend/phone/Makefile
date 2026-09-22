lint:
	dart fix --apply && dart format .

openapi:
	dart run swagger_parser
	dart run build_runner build --build-filter="lib/generated/**"

slang:
	dart run slang
