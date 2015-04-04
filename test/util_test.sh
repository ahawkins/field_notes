#!/usr/bin/env bats

setup() {
	[ -n "$UTIL" ]
	[ -n "$FIELD_NOTES_PATH" ]
}

@test "fails if FIELD_NOTES_PATH not set" {
	run env FIELD_NOTES_PATH= $UTIL
	[ $status -eq 1 ]
	echo "$output" | grep -q "FIELD_NOTES_PATH"
}

@test "requires if EDITOR not set" {
	run env EDITOR= $UTIL
	[ $status -eq 1 ]
	echo "$output" | grep -q "EDITOR"
}

@test "fails if FIELD_NOTES_PATH is not a directory" {
	[ ! -d "/foo/bar/baz" ] # precondition for "fake" directory

	editor="$(mktemp -t util_test)"
	chmod +x "$editor"
	cat > "$editor" <<-'EOF'
#!/usr/bin/env bash
echo "simulation" > "$1"
EOF

	run env EDITOR="$editor" FIELD_NOTES_PATH="/foo/bar/baz" $UTIL
	[ $status -eq 1 ]
	echo "$output" | grep -q "FIELD_NOTES_PATH"
}

@test "creates appropriate file when EDITOR succeeds" {
	editor="$(mktemp -t util_test)"
	chmod +x "$editor"
	cat > "$editor" <<-'EOF'
#!/usr/bin/env bash
echo "simulation" > "$1"
EOF

	run env EDITOR="$editor" $UTIL example note name
	[ $status -eq 0 ]

	date="$(date "+%Y-%m-%d")"

	[ -e "${FIELD_NOTES_PATH}/${date}-example_note_name.md" ]
}

@test "fails appropriate file when EDITOR fails" {
	editor="$(mktemp -t util_test)"
	chmod +x "$editor"
	cat > "$editor" <<-'EOF'
#!/usr/bin/env bash
exit 1
EOF

	run env EDITOR="$editor" $UTIL example note name
	[ $status -eq 1 ]
}

@test "fails if editor does not write anything" {
	editor="$(mktemp -t util_test)"
	chmod +x "$editor"
	cat > "$editor" <<-'EOF'
#!/usr/bin/env bash
exit 0
EOF

	run env EDITOR="$editor" $UTIL example note name
	[ $status -eq 1 ]
}
