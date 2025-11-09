extends Character
class_name Enemy

func _ready():
    super._ready()
    configure_as("right", "enemy")   # 화면 오른쪽에 서서 왼쪽을 봄(-1)
