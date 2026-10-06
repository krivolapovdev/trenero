lint:
	dart fix --apply && dart format .

swagger:
	rm -rf lib/generated
	dart run swagger_parser
	dart run build_runner build --build-filter="lib/generated/**"

slang:
	dart run slang
