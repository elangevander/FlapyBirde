extends Node
## Autoload "EventBus" (modular concept: komunikasi UI <-> game).
## Hanya berisi sinyal. Main memancarkan, UI (HUD, dll.) mendengarkan.
## Dengan begini Main tidak perlu tahu node UI apa saja yang ada.

signal game_ready                    # game baru siap, menunggu klik pertama
signal game_started                  # klik pertama, permainan mulai
signal score_changed(score: int)     # skor bertambah
signal game_ended(score: int, high_score: int, is_new_best: bool)
