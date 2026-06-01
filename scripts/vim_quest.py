#!/usr/bin/env python3
"""
vim_quest.py — vim 操作练习小游戏
用 Python 标准库 curses 实现，无需额外依赖。

运行：python3 vim_quest.py
按 q 退出，r 重置当前关卡。
"""

import curses
import sys
from dataclasses import dataclass, field
from typing import Optional

# ─────────────────────────────────────────────────
# 关卡数据
# ─────────────────────────────────────────────────
# 地图符号：# 墙  @ 出生点  G 目标  T 陷阱  W 单词锚点（可踩，加分）空格 通道
LEVELS = [
    {
        "id": 1,
        "title": "Level 1 - Basic Movement",
        "hint": "Use  h←  j↓  k↑  l→  to reach  G",
        "allowed_keys": {"h", "j", "k", "l"},
        "map": [
            "############",
            "#@         #",
            "#  ######  #",
            "#  #    #  #",
            "#  # ## #  #",
            "#    ##  G #",
            "############",
        ],
        "win_condition": "reach_goal",
        "lives": 3,
    },
    {
        "id": 2,
        "title": "Level 2 - Word Jump",
        "hint": "Use  w(next word)  b(prev word)  e(word end)  to reach  G",
        "allowed_keys": {"w", "b", "e", "h", "j", "k", "l"},
        "map": [
            "####################",
            "#@  T  W     T   W #",
            "#                  #",
            "#  T     W      T  #",
            "#                  #",
            "#   W    T   W   G #",
            "####################",
        ],
        "win_condition": "reach_goal",
        "lives": 3,
    },
    {
        "id": 3,
        "title": "Level 3 - Line Start / End",
        "hint": "Use  0(line start)  ^(first char)  $(line end)  hjkl",
        "allowed_keys": {"0", "^", "$", "h", "j", "k", "l"},
        "map": [
            "####################",
            "#        T     T   #",
            "#@  T              #",
            "#        T     T   #",
            "#   T          T   #",
            "#                  #",
            "#G                 #",
            "####################",
        ],
        "win_condition": "reach_goal",
        "lives": 5,
    },
    {
        "id": 4,
        "title": "Level 4 - Find Char",
        "hint": "Use  f{c}(find→)  F{c}(find←)  t{c}(till→)  T{c}(till←)  hjkl",
        "allowed_keys": {"f", "F", "t", "T", "h", "j", "k", "l"},
        "map": [
            "####################",
            "#@a  b  c  d  e  f #",
            "#                  #",
            "# g  h  i  j  k    #",
            "#                  #",
            "#    l  m  n  o  G #",
            "####################",
        ],
        "win_condition": "reach_goal",
        "lives": 3,
    },
    {
        "id": 5,
        "title": "Level 5 - File Jump",
        "hint": "Use  gg(top)  G(bottom)  {n}G(line n)  hjkl  — visit 1,2,3 in order",
        "allowed_keys": {"g", "G", "h", "j", "k", "l",
                         "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"},
        "map": [
            "################",
            "#@            1#",
            "#              #",
            "#              #",
            "#              #",
            "#2             #",
            "#              #",
            "#              #",
            "#              #",
            "#             3#",
            "#              #",
            "#           G  #",
            "################",
        ],
        "win_condition": "visit_all",   # 需要按顺序踩 1 2 3 再到 G
        "visit_order": ["1", "2", "3"],
        "lives": 5,
    },
]


# ─────────────────────────────────────────────────
# 数据类
# ─────────────────────────────────────────────────
@dataclass
class Command:
    key: str          # 命令标识：h/j/k/l/w/b/e/0/^/$/f/F/t/T/gg/G
    arg: str = ""     # f/t 等命令的目标字符
    count: int = 1    # 数字前缀，如 3G


@dataclass
class GameState:
    level_index: int = 0
    score: int = 0
    lives: int = 3

    # 运行时由 reset_level 填充
    player_row: int = 0
    player_col: int = 0
    grid: list = field(default_factory=list)   # list[list[str]]
    history: list = field(default_factory=list)  # 最近输入记录
    visited: list = field(default_factory=list)  # L5 已访问锚点
    message: str = ""

    def current_level(self):
        return LEVELS[self.level_index]

    def reset_level(self):
        lvl = self.current_level()
        self.lives = lvl["lives"]
        self.history = []
        self.visited = []
        self.message = ""
        # 解析地图，找出 @ 位置后替换为空格
        raw = lvl["map"]
        self.grid = [list(row) for row in raw]
        for r, row in enumerate(self.grid):
            for c, ch in enumerate(row):
                if ch == "@":
                    self.player_row = r
                    self.player_col = c
                    self.grid[r][c] = " "
                    return

    def add_history(self, s: str):
        self.history.append(s)
        if len(self.history) > 12:
            self.history.pop(0)

    def cell(self, r: int, c: int) -> str:
        if 0 <= r < len(self.grid) and 0 <= c < len(self.grid[r]):
            return self.grid[r][c]
        return "#"


# ─────────────────────────────────────────────────
# 输入处理（多字符命令缓冲）
# ─────────────────────────────────────────────────
class InputHandler:
    def __init__(self):
        self._pending: str = ""    # "" / "f" / "F" / "t" / "T" / "g" / 数字串

    def feed(self, key_code: int) -> Optional[Command]:
        """
        返回 Command（命令完整）或 None（等待更多输入）。
        """
        try:
            ch = chr(key_code)
        except (ValueError, OverflowError):
            self._pending = ""
            return None

        # ── 等待 f/F/t/T 的目标字符 ──────────────
        if self._pending in ("f", "F", "t", "T"):
            cmd = Command(key=self._pending, arg=ch)
            self._pending = ""
            return cmd

        # ── 等待 g 的第二个字符 ──────────────────
        if self._pending == "g":
            if ch == "g":
                self._pending = ""
                return Command(key="gg")
            self._pending = ""
            return None   # 其他字符：丢弃

        # ── 等待数字前缀 + G ─────────────────────
        if self._pending and self._pending.isdigit():
            if ch.isdigit():
                self._pending += ch
                return None
            if ch == "G":
                n = int(self._pending)
                self._pending = ""
                return Command(key="G", count=n)
            # 非数字非G：放弃数字，重新处理当前字符
            self._pending = ""
            return self.feed(key_code)

        # ── 新命令开始 ───────────────────────────
        if ch in ("f", "F", "t", "T", "g"):
            self._pending = ch
            return None
        if ch.isdigit() and ch != "0":   # 0 是独立命令，不作数字前缀
            self._pending = ch
            return None

        # 单字符命令直接返回
        simple = {"h", "j", "k", "l", "w", "b", "e", "0", "^", "$", "G"}
        if ch in simple:
            self._pending = ""
            return Command(key=ch)

        self._pending = ""
        return None

    def clear(self):
        self._pending = ""

    @property
    def pending(self) -> str:
        return self._pending


# ─────────────────────────────────────────────────
# 关卡引擎（移动逻辑）
# ─────────────────────────────────────────────────
class LevelEngine:

    def apply(self, cmd: Command, state: GameState) -> dict:
        """
        执行命令，更新 state，返回 {"trap": bool, "won": bool}
        """
        r, c = state.player_row, state.player_col
        nr, nc = r, c
        lvl = state.current_level()

        k = cmd.key

        # hjkl
        if k == "h":
            nr, nc = r, c - cmd.count
        elif k == "j":
            nr, nc = r + cmd.count, c
        elif k == "k":
            nr, nc = r - cmd.count, c
        elif k == "l":
            nr, nc = r, c + cmd.count

        # w: 向右找下一个单词起始（空格→非空格）
        elif k == "w":
            nr, nc = self._word_forward(state, r, c, cmd.count)

        # b: 向左找上一个单词起始
        elif k == "b":
            nr, nc = self._word_backward(state, r, c, cmd.count)

        # e: 向右找单词结尾（非空格→空格 前一格）
        elif k == "e":
            nr, nc = self._word_end(state, r, c, cmd.count)

        # 0: 行首（第0列）
        elif k == "0":
            nr, nc = r, 0

        # ^: 行首第一个非空格
        elif k == "^":
            nr, nc = self._first_nonspace(state, r)

        # $: 行尾最后一个非墙格
        elif k == "$":
            nr, nc = self._line_end(state, r)

        # f/t: 向右查找字符
        elif k in ("f", "t"):
            found_c = self._find_char_right(state, r, c, cmd.arg)
            if found_c is not None:
                offset = 0 if k == "f" else -1
                nr, nc = r, found_c + offset

        # F/T: 向左查找字符
        elif k in ("F", "T"):
            found_c = self._find_char_left(state, r, c, cmd.arg)
            if found_c is not None:
                offset = 0 if k == "F" else 1
                nr, nc = r, found_c + offset

        # gg: 跳到地图第一个可走行
        elif k == "gg":
            nr, nc = self._first_walkable_row(state)

        # G: 跳到指定行（count）或最后一个可走行
        elif k == "G":
            if cmd.count != 1:
                target_row = cmd.count - 1
            else:
                target_row = self._last_walkable_row(state)
            nr = max(0, min(target_row, len(state.grid) - 1))
            nc = c

        # 碰撞检测（允许多步时逐格检查）
        nr, nc = self._clamp_move(state, r, c, nr, nc)
        state.player_row, state.player_col = nr, nc

        # 踩格效果
        cell = state.cell(nr, nc)
        trap = False
        won = False

        if cell == "T":
            trap = True
            state.message = "Ouch! Trap!"
        elif cell == "W":
            state.score += 10
            state.message = "+10 word anchor!"
            state.grid[nr][nc] = " "   # 拾取后消失
        elif cell == "G":
            won = self._check_win(state)
            if won:
                state.message = "Cleared!"
        elif cell in ("1", "2", "3"):
            # L5 按顺序访问锚点
            expected = lvl.get("visit_order", [])
            if expected:
                next_needed = None
                for v in expected:
                    if v not in state.visited:
                        next_needed = v
                        break
                if cell == next_needed:
                    state.visited.append(cell)
                    state.score += 20
                    state.message = f"Checkpoint {cell}! ({len(state.visited)}/{len(expected)})"
                    state.grid[nr][nc] = " "
                else:
                    state.message = f"Need checkpoint {next_needed} first!"
        else:
            state.message = ""

        return {"trap": trap, "won": won}

    # ─── 辅助：移动限制 ───────────────────────────
    def _clamp_move(self, state: GameState, r0: int, c0: int, r1: int, c1: int):
        """沿直线逐格移动，遇墙停在前一格。"""
        dr = 0 if r1 == r0 else (1 if r1 > r0 else -1)
        dc = 0 if c1 == c0 else (1 if c1 > c0 else -1)
        r, c = r0, c0
        # 最多走 max(map) 步
        for _ in range(max(len(state.grid), max(len(row) for row in state.grid)) + 1):
            nr, nc = r + dr, c + dc
            if state.cell(nr, nc) == "#":
                break
            r, c = nr, nc
            if r == r1 and c == c1:
                break
        return r, c

    # ─── 单词跳转 ─────────────────────────────────
    def _word_forward(self, state: GameState, r: int, c: int, count: int):
        for _ in range(count):
            row = state.grid[r]
            c += 1
            # 跳过非空格
            while c < len(row) and row[c] not in (" ", "#"):
                c += 1
            # 跳过空格
            while c < len(row) and row[c] in (" ", "#"):
                c += 1
            c = min(c, len(row) - 1)
        return r, c

    def _word_backward(self, state: GameState, r: int, c: int, count: int):
        for _ in range(count):
            row = state.grid[r]
            c -= 1
            while c >= 0 and row[c] in (" ", "#"):
                c -= 1
            while c > 0 and row[c - 1] not in (" ", "#"):
                c -= 1
            c = max(c, 0)
        return r, c

    def _word_end(self, state: GameState, r: int, c: int, count: int):
        for _ in range(count):
            row = state.grid[r]
            c += 1
            while c < len(row) and row[c] in (" ", "#"):
                c += 1
            while c + 1 < len(row) and row[c + 1] not in (" ", "#"):
                c += 1
            c = min(c, len(row) - 1)
        return r, c

    # ─── 行定位 ───────────────────────────────────
    def _first_nonspace(self, state: GameState, r: int):
        row = state.grid[r]
        for c, ch in enumerate(row):
            if ch not in (" ", "#"):
                return r, c
        return r, 0

    def _line_end(self, state: GameState, r: int):
        row = state.grid[r]
        for c in range(len(row) - 1, -1, -1):
            if row[c] != "#":
                return r, c
        return r, 0

    # ─── 字符查找 ─────────────────────────────────
    def _find_char_right(self, state: GameState, r: int, c: int, target: str):
        row = state.grid[r]
        for nc in range(c + 1, len(row)):
            if row[nc] == target:
                return nc
        return None

    def _find_char_left(self, state: GameState, r: int, c: int, target: str):
        row = state.grid[r]
        for nc in range(c - 1, -1, -1):
            if row[nc] == target:
                return nc
        return None

    # ─── 行跳转 ───────────────────────────────────
    def _first_walkable_row(self, state: GameState):
        for r, row in enumerate(state.grid):
            for c, ch in enumerate(row):
                if ch != "#":
                    return r, c
        return 0, 0

    def _last_walkable_row(self, state: GameState):
        for r in range(len(state.grid) - 1, -1, -1):
            row = state.grid[r]
            for c, ch in enumerate(row):
                if ch != "#":
                    return r
        return len(state.grid) - 1

    # ─── 胜利判定 ─────────────────────────────────
    def _check_win(self, state: GameState) -> bool:
        lvl = state.current_level()
        if lvl["win_condition"] == "reach_goal":
            return True
        if lvl["win_condition"] == "visit_all":
            required = set(lvl.get("visit_order", []))
            return required.issubset(set(state.visited))
        return False


# ─────────────────────────────────────────────────
# 渲染器
# ─────────────────────────────────────────────────
# 颜色对 ID
C_PLAYER = 1
C_GOAL   = 2
C_WALL   = 3
C_TRAP   = 4
C_WORD   = 5
C_UI     = 6
C_HINT   = 7
C_MSG    = 8


class Renderer:
    def __init__(self, stdscr):
        self.scr = stdscr
        self._init_colors()

    def _init_colors(self):
        curses.start_color()
        curses.use_default_colors()
        curses.init_pair(C_PLAYER, curses.COLOR_CYAN,    -1)
        curses.init_pair(C_GOAL,   curses.COLOR_GREEN,   -1)
        curses.init_pair(C_WALL,   curses.COLOR_RED,     -1)
        curses.init_pair(C_TRAP,   curses.COLOR_YELLOW,  -1)
        curses.init_pair(C_WORD,   curses.COLOR_MAGENTA, -1)
        curses.init_pair(C_UI,     curses.COLOR_WHITE,   -1)
        curses.init_pair(C_HINT,   curses.COLOR_CYAN,    -1)
        curses.init_pair(C_MSG,    curses.COLOR_YELLOW,  -1)

    def draw(self, state: GameState):
        scr = self.scr
        scr.erase()
        max_y, max_x = scr.getmaxyx()
        lvl = state.current_level()

        # ── 顶部标题区（行 0-2）──────────────────
        title = f"  {lvl['title']}   Score:{state.score}  Lives:{'❤'*state.lives}"
        self._safe_addstr(scr, 0, 0, title[:max_x - 1], curses.color_pair(C_UI) | curses.A_BOLD)
        hint = f"  {lvl['hint']}"
        self._safe_addstr(scr, 1, 0, hint[:max_x - 1], curses.color_pair(C_HINT))

        # ── 地图区（居中）────────────────────────
        map_start_row = 3
        map_rows = len(state.grid)
        map_cols = max(len(r) for r in state.grid) if state.grid else 0
        map_display_rows = min(map_rows, max_y - map_start_row - 4)
        col_offset = max(0, (max_x - map_cols) // 2)

        for dr in range(map_display_rows):
            r = dr
            screen_row = map_start_row + dr
            if screen_row >= max_y - 3:
                break
            row_data = state.grid[r]
            for c, ch in enumerate(row_data):
                screen_col = col_offset + c
                if screen_col >= max_x - 1:
                    break
                if r == state.player_row and c == state.player_col:
                    self._safe_addch(scr, screen_row, screen_col,
                                     "@", curses.color_pair(C_PLAYER) | curses.A_BOLD)
                elif ch == "#":
                    self._safe_addch(scr, screen_row, screen_col,
                                     "#", curses.color_pair(C_WALL))
                elif ch == "G":
                    self._safe_addch(scr, screen_row, screen_col,
                                     "G", curses.color_pair(C_GOAL) | curses.A_BOLD)
                elif ch == "T":
                    self._safe_addch(scr, screen_row, screen_col,
                                     "T", curses.color_pair(C_TRAP) | curses.A_BOLD)
                elif ch == "W":
                    self._safe_addch(scr, screen_row, screen_col,
                                     "W", curses.color_pair(C_WORD))
                elif ch in ("1", "2", "3"):
                    self._safe_addch(scr, screen_row, screen_col,
                                     ch, curses.color_pair(C_GOAL))
                else:
                    self._safe_addch(scr, screen_row, screen_col, ch)

        # ── 底部状态区（最后 3 行）────────────────
        bottom = max_y - 3
        # 消息行
        msg = state.message or ""
        self._safe_addstr(scr, bottom, 0,
                          f"  {msg}"[:max_x - 1],
                          curses.color_pair(C_MSG))
        # 历史行
        hist = "  " + "  ".join(f"[{h}]" for h in state.history[-10:])
        self._safe_addstr(scr, bottom + 1, 0, hist[:max_x - 1],
                          curses.color_pair(C_UI))
        # 操作提示
        pending_info = f"  pending: '{state._input_handler_pending}'" \
            if hasattr(state, "_input_handler_pending") and state._input_handler_pending else ""
        help_line = f"  q=quit  r=reset  {pending_info}"
        self._safe_addstr(scr, bottom + 2, 0, help_line[:max_x - 1],
                          curses.color_pair(C_UI))

        scr.refresh()

    def draw_banner(self, state: GameState, lines: list, color_pair: int):
        """居中显示多行横幅（用于通关/死亡界面）。"""
        scr = self.scr
        max_y, max_x = scr.getmaxyx()
        start_row = max(0, max_y // 2 - len(lines) // 2)
        for i, line in enumerate(lines):
            col = max(0, (max_x - len(line)) // 2)
            self._safe_addstr(scr, start_row + i, col, line,
                              curses.color_pair(color_pair) | curses.A_BOLD)
        scr.refresh()

    @staticmethod
    def _safe_addstr(scr, y: int, x: int, s: str, attr: int = 0):
        try:
            scr.addstr(y, x, s, attr)
        except curses.error:
            pass

    @staticmethod
    def _safe_addch(scr, y: int, x: int, ch: str, attr: int = 0):
        try:
            scr.addch(y, x, ch, attr)
        except curses.error:
            pass


# ─────────────────────────────────────────────────
# 主循环
# ─────────────────────────────────────────────────
def main(stdscr):
    curses.curs_set(0)
    stdscr.keypad(True)

    state = GameState()
    state.reset_level()

    handler = InputHandler()
    engine = LevelEngine()
    renderer = Renderer(stdscr)

    while True:
        # 将 pending 暴露给 Renderer 用于底部显示
        state._input_handler_pending = handler.pending

        renderer.draw(state)
        key_code = stdscr.getch()

        # 全局快捷键
        if key_code == ord("q"):
            break
        if key_code == ord("r"):
            state.reset_level()
            handler.clear()
            continue

        # 解析命令（可能需要多次按键）
        cmd = handler.feed(key_code)
        if cmd is None:
            # 正在等待多字符命令的后续输入，界面已通过 pending 提示
            continue

        lvl = state.current_level()

        # 检查是否为当前关允许的按键
        # 对于 f/F/t/T，allowed_keys 里只需包含 "f"/"F"/"t"/"T" 即可
        if cmd.key not in lvl["allowed_keys"]:
            state.add_history(f"!{cmd.key}")
            state.message = f"'{cmd.key}' is not allowed in this level!"
            continue

        # 执行命令
        result = engine.apply(cmd, state)
        state.add_history(cmd.key + cmd.arg + (str(cmd.count) if cmd.count != 1 else ""))

        # 陷阱处理
        if result["trap"]:
            state.lives -= 1
            if state.lives <= 0:
                renderer.draw(state)
                renderer.draw_banner(state, [
                    "",
                    " ╔══════════════════╗ ",
                    " ║   GAME  OVER     ║ ",
                    " ╚══════════════════╝ ",
                    "   Press any key...   ",
                ], C_TRAP)
                stdscr.getch()
                state.level_index = 0
                state.score = 0
                state.reset_level()
                handler.clear()
                continue

        # 通关处理
        if result["won"]:
            state.score += 100
            renderer.draw(state)
            renderer.draw_banner(state, [
                "",
                " ╔══════════════════╗ ",
                f" ║  Level {state.level_index + 1} Clear!  ║ ",
                " ╚══════════════════╝ ",
                "   Press any key...   ",
            ], C_GOAL)
            stdscr.getch()
            state.level_index += 1
            if state.level_index >= len(LEVELS):
                # 全通关
                renderer.draw_banner(state, [
                    "",
                    " ╔══════════════════════════╗ ",
                    " ║  Congratulations!         ║ ",
                    " ║  You mastered vim moves!  ║ ",
                    f" ║  Final Score: {state.score:<10} ║ ",
                    " ╚══════════════════════════╝ ",
                    "     Press any key to quit    ",
                ], C_GOAL)
                stdscr.getch()
                break
            state.reset_level()
            handler.clear()


if __name__ == "__main__":
    try:
        curses.wrapper(main)
    except KeyboardInterrupt:
        pass
    print("Thanks for playing vim_quest!")
