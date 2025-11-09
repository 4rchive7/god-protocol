extends Character
class_name Player

func _ready():
    super._ready()
    configure_as("left", "player")   # 화면 왼쪽에 서서 오른쪽을 봄(+1)
