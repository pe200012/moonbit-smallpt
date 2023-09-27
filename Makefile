run:
	moon build
	wat2wasm target/build/main/main.wat --output=target/smallpt.wasm
	npx serve