xmomap -pke して　主要なものだけリストアップ

```
keycode   9 = Escape NoSymbol Escape
keycode  10 = 1 exclam 1 exclam
keycode  11 = 2 quotedbl 2 at
keycode  12 = 3 numbersign 3 numbersign
keycode  13 = 4 dollar 4 dollar
keycode  14 = 5 percent 5 percent
keycode  15 = 6 ampersand 6 asciicircum
keycode  16 = 7 apostrophe 7 ampersand
keycode  17 = 8 parenleft 8 asterisk
keycode  18 = 9 parenright 9 parenleft
keycode  19 = 0 asciitilde 0 parenright
keycode  20 = minus equal minus underscore
keycode  21 = asciicircum asciitilde equal plus
keycode  22 = BackSpace BackSpace BackSpace BackSpace
keycode  23 = Tab ISO_Left_Tab Tab ISO_Left_Tab
keycode  24 = q Q q Q
keycode  25 = w W w W
keycode  26 = e E e E
keycode  27 = r R r R
keycode  28 = t T t T
keycode  29 = y Y y Y
keycode  30 = u U u U
keycode  31 = i I i I
keycode  32 = o O o O
keycode  33 = p P p P
keycode  34 = at grave bracketleft braceleft
keycode  35 = bracketleft braceleft bracketright braceright
keycode  36 = Return NoSymbol Return
keycode  37 = Control_L NoSymbol Control_L
keycode  38 = a A a A
keycode  39 = s S s S
keycode  40 = d D d D
keycode  41 = f F f F
keycode  42 = g G g G
keycode  43 = h H h H
keycode  44 = j J j J
keycode  45 = k K k K
keycode  46 = l L l L
keycode  47 = semicolon plus semicolon colon
keycode  48 = colon asterisk apostrophe quotedbl
keycode  49 = Zenkaku_Hankaku Kanji grave asciitilde →　左下三本線のキー
keycode  50 = Shift_L NoSymbol Shift_L
keycode  51 = bracketright braceright backslash bar
keycode  52 = z Z z Z
keycode  53 = x X x X
keycode  54 = c C c C
keycode  55 = v V v V
keycode  56 = b B b B
keycode  57 = n N n N
keycode  58 = m M m M
keycode  59 = comma less comma less
keycode  60 = period greater period greater
keycode  61 = slash question slash question
keycode  62 = Shift_R NoSymbol Shift_R
keycode  64 = Alt_L Meta_L Alt_L Meta_L
keycode  65 = space NoSymbol space
keycode  97 = backslash underscore backslash underscore
keycode 100 = Henkan_Mode NoSymbol Henkan_Mode
keycode 101 = Hiragana_Katakana Romaji Hiragana_Katakana Romaji
keycode 102 = Muhenkan NoSymbol Muhenkan
keycode 108 = Alt_R Meta_R Alt_R Meta_R
keycode 111 = Up NoSymbol Up
keycode 113 = Left NoSymbol Left
keycode 114 = Right NoSymbol Right
keycode 116 = Down NoSymbol Down
keycode 132 = backslash bar backslash bar
keycode 133 = Super_L NoSymbol Super_L
keycode 134 = Super_R NoSymbol Super_R
```

xmodmap

```
xmodmap:  up to 4 keys per modifier, (keycodes in parentheses):

shift       Shift_L (0x32),  Shift_R (0x3e)
lock        Eisu_toggle (0x42)
control     Control_L (0x25),  Control_R (0x69)
mod1        Alt_L (0x40),  Alt_R (0x6c),  Meta_L (0xcd)
mod2        Num_Lock (0x4d)
mod3      
mod4        Super_L (0x85),  Super_R (0x86),  Super_L (0xce),  Hyper_L (0xcf)
mod5        ISO_Level3_Shift (0x5c),  Mode_switch (0xcb)
```

https://github.com/k0kubun/xremap/blob/master/mrblib/xremap/key_expression.rb#L27-L35

```ruby
# 'C' means Ctrl
# 'M' means Alt
# 'Super' means Win

when 'C', 'Ctrl'
  mask |= X11::ControlMask
when 'M', 'Alt'
  mask |= X11::Mod1Mask
when 'Super', 'Win'
  mask |= X11::Mod4Mask
when 'Shift'
  mask |= X11::ShiftMask
end
```

# 変更したい部分
## Cmdキー的なものを作る

## 日本語・英数の切り替え
- 右上のアイコンから、ツール→プロパティ
  - 一般タブ
    - キー設定 → 編集
    - ↓の設定をインポート
    - 変更内容は、直接入力、入力文字なし、変換前入力中、変換中のそれぞれで
      - Henkan IMEを無効化
      - Muhenkan ひらがなに入力変換
- 一応参考
  - http://rubellum.hatenablog.com/entry/2012/04/02/140154

```
status	key	command
Composition	Backspace	Backspace
Composition	Ctrl a	MoveCursorToBeginning
Composition	Ctrl Backspace	Backspace
Composition	Ctrl d	MoveCursorRight
Composition	Ctrl Down	MoveCursorToEnd
Composition	Ctrl e	MoveCursorToBeginning
Composition	Ctrl Enter	Commit
Composition	Ctrl f	MoveCursorToEnd
Composition	Ctrl g	Delete
Composition	Ctrl h	Backspace
Composition	Ctrl i	ConvertToFullKatakana
Composition	Ctrl k	MoveCursorLeft
Composition	Ctrl l	MoveCursorRight
Composition	Ctrl Left	MoveCursorToBeginning
Composition	Ctrl m	Commit
Composition	Ctrl n	MoveCursorToEnd
Composition	Ctrl o	ConvertToHalfWidth
Composition	Ctrl p	ConvertToFullAlphanumeric
Composition	Ctrl Right	MoveCursorToEnd
Composition	Ctrl s	MoveCursorLeft
Composition	Ctrl Shift Space	InsertFullSpace
Composition	Ctrl Space	InsertHalfSpace
Composition	Ctrl t	ConvertToHalfAlphanumeric
Composition	Ctrl u	ConvertToHiragana
Composition	Ctrl Up	MoveCursorToBeginning
Composition	Ctrl x	MoveCursorToEnd
Composition	Ctrl z	Cancel
Composition	Delete	Delete
Composition	Down	MoveCursorToEnd
Composition	Eisu	ToggleAlphanumericMode
Composition	End	MoveCursorToEnd
Composition	Enter	Commit
Composition	ESC	Cancel
Composition	F10	ConvertToHalfAlphanumeric
Composition	F2	ConvertWithoutHistory
Composition	F6	ConvertToHiragana
Composition	F7	ConvertToFullKatakana
Composition	F8	ConvertToHalfWidth
Composition	F9	ConvertToFullAlphanumeric
Composition	Hankaku/Zenkaku	IMEOff
Composition	Henkan	Convert
Composition	Hiragana	InputModeHiragana
Composition	Home	MoveCursorToBeginning
Composition	Katakana	InputModeFullKatakana
Composition	Left	MoveCursorLeft
Composition	Muhenkan	SwitchKanaType
Composition	Right	MoveCursorRight
Composition	Shift Backspace	Backspace
Composition	Shift ESC	Cancel
Composition	Shift Left	MoveCursorLeft
Composition	Shift Muhenkan	ConvertToFullAlphanumeric
Composition	Shift Right	MoveCursorRight
Composition	Shift Space	Convert
Composition	Space	Convert
Composition	Tab	PredictAndConvert
Conversion	Backspace	Cancel
Conversion	Ctrl a	SegmentFocusFirst
Conversion	Ctrl Backspace	Cancel
Conversion	Ctrl d	SegmentFocusRight
Conversion	Ctrl Down	CommitOnlyFirstSegment
Conversion	Ctrl e	ConvertPrev
Conversion	Ctrl Enter	Commit
Conversion	Ctrl f	SegmentFocusLast
Conversion	Ctrl g	Cancel
Conversion	Ctrl h	Cancel
Conversion	Ctrl i	ConvertToFullKatakana
Conversion	Ctrl k	SegmentWidthShrink
Conversion	Ctrl l	SegmentWidthExpand
Conversion	Ctrl Left	SegmentFocusFirst
Conversion	Ctrl m	Commit
Conversion	Ctrl n	CommitOnlyFirstSegment
Conversion	Ctrl o	ConvertToHalfWidth
Conversion	Ctrl p	ConvertToFullAlphanumeric
Conversion	Ctrl Right	SegmentFocusLast
Conversion	Ctrl s	SegmentFocusLeft
Conversion	Ctrl Shift Space	InsertFullSpace
Conversion	Ctrl Space	InsertHalfSpace
Conversion	Ctrl t	ConvertToHalfAlphanumeric
Conversion	Ctrl u	ConvertToHiragana
Conversion	Ctrl Up	ConvertPrev
Conversion	Ctrl x	ConvertNext
Conversion	Ctrl z	Cancel
Conversion	Delete	Cancel
Conversion	Down	ConvertNext
Conversion	Eisu	ToggleAlphanumericMode
Conversion	End	SegmentFocusLast
Conversion	Enter	Commit
Conversion	ESC	Cancel
Conversion	F10	ConvertToHalfAlphanumeric
Conversion	F6	ConvertToHiragana
Conversion	F7	ConvertToFullKatakana
Conversion	F8	ConvertToHalfWidth
Conversion	F9	ConvertToFullAlphanumeric
Conversion	Hankaku/Zenkaku	IMEOff
Conversion	Henkan	ConvertNext
Conversion	Hiragana	InputModeHiragana
Conversion	Home	SegmentFocusFirst
Conversion	Katakana	InputModeFullKatakana
Conversion	Left	SegmentFocusLeft
Conversion	Muhenkan	SwitchKanaType
Conversion	PageDown	ConvertNextPage
Conversion	PageUp	ConvertPrevPage
Conversion	Right	SegmentFocusRight
Conversion	Shift Backspace	Cancel
Conversion	Shift Down	ConvertNextPage
Conversion	Shift ESC	Cancel
Conversion	Shift Henkan	ConvertPrev
Conversion	Shift Left	SegmentWidthShrink
Conversion	Shift Muhenkan	ConvertToFullAlphanumeric
Conversion	Shift Right	SegmentWidthExpand
Conversion	Shift Space	ConvertPrev
Conversion	Shift Tab	ConvertPrev
Conversion	Shift Up	ConvertPrevPage
Conversion	Space	ConvertNext
Conversion	Tab	PredictAndConvert
Conversion	Up	ConvertPrev
DirectInput	Eisu	IMEOn
DirectInput	F13	IMEOn
DirectInput	Hankaku/Zenkaku	IMEOn
DirectInput	Henkan	Reconvert
DirectInput	Hiragana	IMEOn
DirectInput	Katakana	IMEOn
Precomposition	Backspace	Revert
Precomposition	Ctrl Backspace	Undo
Precomposition	Ctrl Shift Space	InsertFullSpace
Precomposition	Eisu	ToggleAlphanumericMode
Precomposition	Hankaku/Zenkaku	IMEOff
Precomposition	Hiragana	InputModeHiragana
Precomposition	Henkan	Reconvert
Precomposition	Katakana	InputModeFullKatakana
Precomposition	Muhenkan	InputModeSwitchKanaType
Precomposition	Shift Muhenkan	ToggleAlphanumericMode
Precomposition	Shift Space	InsertAlternateSpace
Precomposition	Space	InsertSpace
Prediction	Ctrl Delete	DeleteSelectedCandidate
Suggestion	Down	PredictAndConvert
Suggestion	Shift Enter	CommitFirstSuggestion
DirectInput	Muhenkan	IMEOff
DirectInput	Henkan	InputModeHiragana
Precomposition	Muhenkan	IMEOff
Precomposition	Henkan	InputModeHiragana
Composition	Muhenkan	IMEOff
Composition	Henkan	InputModeHiragana
Conversion	Muhenkan	IMEOff
Conversion	Henkan	InputModeHiragana
Composition	ASCII	InsertCharacter
Composition	Kanji	IMEOff
Composition	OFF	IMEOff
Composition	ON	IMEOn
Conversion	Kanji	IMEOff
Conversion	OFF	IMEOff
Conversion	ON	IMEOn
DirectInput	Kanji	IMEOn
DirectInput	ON	IMEOn
Precomposition	ASCII	InsertCharacter
Precomposition	Kanji	IMEOff
Precomposition	OFF	IMEOff
Precomposition	ON	IMEOn
```
