# Part 1 — fixes for "not incrementing" and sync between s1 and display
# ==============================================================================
# BUG 1: s1 is never initialized.
#   You use s1 for the current value (key1 add, key2 sub) but never set it at start.
#   So s1 can be garbage (e.g. 0xFFFFFFFF). Then in key1 you do:
#     bge s1, t6, poll   # if s1 >= 15, go back to poll
#   If s1 is huge, this is always true → you always jump to poll and never
#   increment. So key1 "does nothing" (not incrementing anymore).
#
# FIX: Initialize s1 to 1 at start and show 1 on the LEDs (per spec).
# ==============================================================================
# BUG 2: key0 displays 1 but never sets s1 = 1.
#   You do: sw s2, 0(t2)  (display 1) but s1 is unchanged.
#   So after key0, the LEDs show 1 but s1 might still be 0 or garbage.
#   Then key1 does addi s1, s1, 1 and sw s1 — so the "stored" value and
#   display get out of sync. Also if s1 was never fixed, key1 can keep
#   hitting bge s1, t6, poll.
#
# FIX: In key0, set s1 = 1 (e.g. li s1, 1 or use s2) so s1 matches the display.
# ==============================================================================
# BUG 3 (optional): key2 when display is blank (s1=0).
#   You have ble s1, s2, poll (s2=1). So when s1 is 0, 0 <= 1 → go to poll.
#   So you don't change anything. Spec says KEY2 when blank should bring to 1.
#
# FIX: In key2, if s1 is 0, set s1=1 and display 1; else if s1 > 1, decrement.
# ==============================================================================

# Minimal changes to your code:
# 1) After "li t6, 15" add:
#    li s1, 1
#    sw s1, 0(t2)
# 2) In key0, before "sw s2, 0(t2)" add:
#    li s1, 1
# 3) In key2, to handle blank → 1: when s1 is 0, set s1=1 and display 1 (e.g. beqz s1, key0 or add a check).
