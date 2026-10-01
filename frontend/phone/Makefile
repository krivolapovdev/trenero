lint:
	dart fix --apply && dart format .

swagger:
	dart run swagger_parser
	dart run build_runner build --build-filter="lib/generated/**" --delete-conflicting-outputs

slang:
	dart run slang
