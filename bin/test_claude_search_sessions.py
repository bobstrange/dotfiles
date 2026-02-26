#!/usr/bin/env python3
"""Unit tests for claude-search-sessions.py."""

import json
import os
import sys
import tempfile
import unittest

# Import the module under test by manipulating the path
sys.path.insert(0, os.path.dirname(__file__))
import importlib

mod = importlib.import_module("executable_claude-search-sessions")
_has_user_message_match = mod._has_user_message_match
_is_user_typed_entry = mod._is_user_typed_entry
_iter_user_text = mod._iter_user_text
_content_search = mod._content_search


def _write_session(entries):
    """Write session entries to a temp JSONL file and return the path.

    Each entry can be:
    - A dict with "role"/"content" keys → wrapped as {"message": entry}
    - A dict with "message" key → written as-is (allows isMeta, etc.)
    """
    f = tempfile.NamedTemporaryFile(mode="w", suffix=".jsonl", delete=False)
    for entry in entries:
        if "message" in entry:
            f.write(json.dumps(entry) + "\n")
        else:
            f.write(json.dumps({"message": entry}) + "\n")
    f.close()
    return f.name


class TestHasUserMessageMatch(unittest.TestCase):
    def tearDown(self):
        if hasattr(self, "_files"):
            for p in self._files:
                os.unlink(p)

    def _track(self, path):
        if not hasattr(self, "_files"):
            self._files = []
        self._files.append(path)
        return path

    # 1. Plain string user message containing query → match
    def test_plain_string_match(self):
        path = self._track(_write_session([
            {"role": "user", "content": "How do I fix performance issues?"},
        ]))
        self.assertTrue(_has_user_message_match(path, "performance"))

    # 2. Plain string user message NOT containing query → no match
    def test_plain_string_no_match(self):
        path = self._track(_write_session([
            {"role": "user", "content": "Hello world"},
        ]))
        self.assertFalse(_has_user_message_match(path, "performance"))

    # 3. User message with text block only (no tool_result), query in text → match
    def test_text_block_only_match(self):
        path = self._track(_write_session([
            {"role": "user", "content": [
                {"type": "text", "text": "Check the performance report"},
            ]},
        ]))
        self.assertTrue(_has_user_message_match(path, "performance"))

    # 4. User message with tool_result + text block, query in text block → no match (skip)
    def test_tool_result_with_text_block_skipped(self):
        path = self._track(_write_session([
            {"role": "user", "content": [
                {"type": "tool_result", "tool_use_id": "x", "content": "ok"},
                {"type": "text", "text": "<system-reminder>performance report data</system-reminder>"},
            ]},
        ]))
        self.assertFalse(_has_user_message_match(path, "performance"))

    # 5. User message with tool_result, query in tool_result content string → no match
    def test_tool_result_content_string_no_match(self):
        path = self._track(_write_session([
            {"role": "user", "content": [
                {"type": "tool_result", "tool_use_id": "x",
                 "content": "performance data here"},
            ]},
        ]))
        self.assertFalse(_has_user_message_match(path, "performance"))

    # 6. User message with tool_result, query in nested tool_result text block → no match
    def test_tool_result_nested_text_block_no_match(self):
        path = self._track(_write_session([
            {"role": "user", "content": [
                {"type": "tool_result", "tool_use_id": "x", "content": [
                    {"type": "text", "text": "performance metrics"},
                ]},
            ]},
        ]))
        self.assertFalse(_has_user_message_match(path, "performance"))

    # 7. Assistant message containing query → no match
    def test_assistant_message_ignored(self):
        path = self._track(_write_session([
            {"role": "assistant", "content": "Here is the performance report"},
        ]))
        self.assertFalse(_has_user_message_match(path, "performance"))

    # 8. Case insensitive matching → match
    def test_case_insensitive(self):
        path = self._track(_write_session([
            {"role": "user", "content": "PERFORMANCE issues"},
        ]))
        self.assertTrue(_has_user_message_match(path, "performance"))

    # 9. Multiple user messages, only one matches → match
    def test_multiple_messages_one_match(self):
        path = self._track(_write_session([
            {"role": "user", "content": "Hello"},
            {"role": "assistant", "content": "Hi there"},
            {"role": "user", "content": "Show me the performance data"},
        ]))
        self.assertTrue(_has_user_message_match(path, "performance"))

    # 10. isMeta=true skill injection with text block containing query → no match
    def test_is_meta_skill_injection_skipped(self):
        path = self._track(_write_session([
            {
                "isMeta": True,
                "message": {
                    "role": "user",
                    "content": [
                        {"type": "text", "text": "Base directory for this skill: /path/to/skill\n"
                         "Ad network performance reports"},
                    ],
                },
            },
        ]))
        self.assertFalse(_has_user_message_match(path, "performance"))

    # 11. isMeta=true with plain string content → no match
    def test_is_meta_plain_string_skipped(self):
        path = self._track(_write_session([
            {
                "isMeta": True,
                "message": {"role": "user", "content": "performance tuning guide"},
            },
        ]))
        self.assertFalse(_has_user_message_match(path, "performance"))

    # 12. Mix of isMeta and real user message → only real message matches
    def test_is_meta_mixed_with_real_message(self):
        path = self._track(_write_session([
            {
                "isMeta": True,
                "message": {
                    "role": "user",
                    "content": [{"type": "text", "text": "skill: performance reports"}],
                },
            },
            {"role": "user", "content": "check the logs"},
        ]))
        self.assertFalse(_has_user_message_match(path, "performance"))
        self.assertTrue(_has_user_message_match(path, "logs"))


class TestIsUserTypedEntry(unittest.TestCase):
    def test_plain_user_message(self):
        obj = {"message": {"role": "user", "content": "hello"}}
        self.assertTrue(_is_user_typed_entry(obj))

    def test_assistant_message(self):
        obj = {"message": {"role": "assistant", "content": "hi"}}
        self.assertFalse(_is_user_typed_entry(obj))

    def test_is_meta_true(self):
        obj = {"isMeta": True, "message": {"role": "user", "content": "skill context"}}
        self.assertFalse(_is_user_typed_entry(obj))

    def test_tool_result_in_content(self):
        obj = {"message": {"role": "user", "content": [
            {"type": "tool_result", "tool_use_id": "x", "content": "ok"},
            {"type": "text", "text": "system context"},
        ]}}
        self.assertFalse(_is_user_typed_entry(obj))

    def test_text_only_list(self):
        obj = {"message": {"role": "user", "content": [
            {"type": "text", "text": "user input"},
        ]}}
        self.assertTrue(_is_user_typed_entry(obj))


class TestIterUserText(unittest.TestCase):
    def test_plain_string(self):
        obj = {"message": {"role": "user", "content": "hello world"}}
        self.assertEqual(list(_iter_user_text(obj)), ["hello world"])

    def test_text_blocks(self):
        obj = {"message": {"role": "user", "content": [
            {"type": "text", "text": "first"},
            {"type": "text", "text": "second"},
        ]}}
        self.assertEqual(list(_iter_user_text(obj)), ["first", "second"])

    def test_skips_non_text_blocks(self):
        obj = {"message": {"role": "user", "content": [
            {"type": "image", "source": "data"},
            {"type": "text", "text": "caption"},
        ]}}
        self.assertEqual(list(_iter_user_text(obj)), ["caption"])

    def test_empty_string_content(self):
        obj = {"message": {"role": "user", "content": ""}}
        self.assertEqual(list(_iter_user_text(obj)), [""])

    def test_missing_content(self):
        obj = {"message": {"role": "user"}}
        # Default is "" (empty string), which is still yielded as a str
        self.assertEqual(list(_iter_user_text(obj)), [""])

    def test_empty_list_content(self):
        obj = {"message": {"role": "user", "content": []}}
        self.assertEqual(list(_iter_user_text(obj)), [])


class TestContentSearch(unittest.TestCase):
    """Integration-style tests for _content_search with user_only flag."""

    def setUp(self):
        self._tmpdir = tempfile.mkdtemp()
        self._orig_projects_dir = mod.PROJECTS_DIR
        mod.PROJECTS_DIR = self._tmpdir

        # Create a session file with both user-typed and tool_result messages
        self._session_id = "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
        session_path = os.path.join(self._tmpdir, f"{self._session_id}.jsonl")
        messages = [
            # Assistant mentions "deploy" but user never typed it
            {"role": "assistant", "content": "Let me deploy the application"},
            # User message with tool_result containing "deploy" in system context
            {"role": "user", "content": [
                {"type": "tool_result", "tool_use_id": "t1", "content": "deployed ok"},
                {"type": "text", "text": "<system-reminder>deploy status</system-reminder>"},
            ]},
            # User actually typed something else
            {"role": "user", "content": "check the logs"},
        ]
        with open(session_path, "w") as f:
            for msg in messages:
                f.write(json.dumps({"message": msg}) + "\n")

    def tearDown(self):
        mod.PROJECTS_DIR = self._orig_projects_dir
        import shutil
        shutil.rmtree(self._tmpdir)

    # 10. _content_search with user_only=True filters correctly
    def test_user_only_filters_false_positive(self):
        result = _content_search("deploy", user_only=True)
        self.assertNotIn(self._session_id, result)

    # 11. _content_search with user_only=False returns all rg matches
    def test_all_mode_includes_match(self):
        result = _content_search("deploy", user_only=False)
        self.assertIn(self._session_id, result)


if __name__ == "__main__":
    unittest.main()
