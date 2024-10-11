extends Node2D

# 0是空位、1是墙（橙色）、2是蛇头（深绿色）、3是蛇身（浅绿色）、4是食物（红色）。
var chess
# 蛇头的位置，由于direction为0，是右，所以蛇头必须位于最右侧。
var snake_head = [1, 3]
# 蛇身体的位置，可以连起来。也可以不连【不过执行到最后总会连起来的~】
var body_point = [[1, 1], [1, 2]]
# 0是右、1是下、2是左、3是上
var direction = 0
# 场景色块
var scene_rect
# 是否启用可以输入（设置该变量以防止蛇原地转头从而死亡）
var is_dir = true

# 判断键位输入
func _input(event: InputEvent) -> void:
	# ESC键退出~
	if event.is_action_pressed("esc"):
		get_tree().change_scene_to_file("res://GameoverScene.tscn")
		return
	# 判断是否按下S键
	elif event.is_action_pressed("move_down"):
		if direction == 0 || direction == 2:
			# 如果该变量等于false，则输入被锁定，无法输入任何键。
			if is_dir:
				is_dir = false
				direction = 1
	# 判断是否按下A键
	elif event.is_action_pressed("move_left"):
		if direction == 1 || direction == 3:
			if is_dir:
				is_dir = false
				direction = 2
	# 判断是否按下D键
	elif event.is_action_pressed("move_right"):
		if direction == 1 || direction == 3:
			if is_dir:
				is_dir = false
				direction = 0
	# 判断是否按下W键
	elif event.is_action_pressed("move_up"):
		if direction == 0 || direction == 2:
			if is_dir:
				is_dir = false
				direction = 3
	else:
		pass

# 该场景初始化的函数。（刚进入该场景时执行一次）
func _ready() -> void:
	# 初始化一次棋盘（60x40，60是宽，40是高。但是参数必须得反着写。。）
	# 该棋盘默认值全部为0
	chess = initialize_2d_array(40, 60, 0)
	# 初始化棋盘上的色块，默认全部为null
	scene_rect = initialize_2d_array(40, 60, null)
	# 判断场景（在关卡选择里选择，参见DifficultyScene.gd）
	match Global.scene:
		# 此处场景为圆形
		2: 
			for i in range(8):
				chess[3][27 + i] = 1
			for i in range(7):
				chess[5 + i][22 - i] = 1
			for i in range(8):
				chess[16 + i][14] = 1
			for i in range(7):
				chess[28 + i][16 + i] = 1
			for i in range(8):
				chess[36][27 + i] = 1
			for i in range(7):
				chess[28 + i][45 - i] = 1
			for i in range(8):
				chess[16 + i][47] = 1
			for i in range(7):
				chess[5 + i][39 + i] = 1
		# 此处场景为桥梁
		3: 
			for i in range(22, 38):
				chess[10][i] = 1
			for i in range(10):
				chess[10 + i][22 - i] = 1
			for i in range(10):
				chess[10 + i][37 + i] = 1
		# 此处场景为风车
		4:
			for i in range(10):
				chess[i][40] = 1
			for i in range(10):
				chess[i + 30][19] = 1
			for i in range(15):
				chess[14][i] = 1
			for i in range(15):
				chess[25][i + 45] = 1
		# 默认场景为方形
		_:
			for i in range(60):
				chess[0][i] = 1
			for i in range(1, 39):
				chess[i][0] = 1
			for i in range(60):
				chess[39][i] = 1
			for i in range(1, 39):
				chess[i][59] = 1
	# 初始化蛇身的位置（参见body_point）
	for i in range(len(body_point)):
		chess[body_point[i][0]][body_point[i][1]] = 3
	# 初始化蛇头的位置（如果初始direction为0【右】，则snake_head的右侧不允许有墙或者蛇身。）
	chess[snake_head[0]][snake_head[1]] = 2
	# 渲染全屏一次（后续就不再执行这个渲染全屏函数了~）
	_reload_scene()
	# 随机生成一次食物
	_rand_food()

# 渲染全屏一次
func _reload_scene():
	# 全屏for循环执行
	for i in range(40):
		for j in range(60):
			# 执行一次draw_scene
			draw_scene(j, i, chess[i][j])

# 重新渲染一次棋盘（但仅渲染蛇的身体）
func _reload_snake(pf: Array):
	# 将棋盘上的蛇更新，并更新蛇头和蛇身。
	chess[pf[0]][pf[1]] = 0
	# 赋值一个蛇头
	chess[snake_head[0]][snake_head[1]] = 2
	for i in body_point:
		# 重新在body_point里赋值3，如果不加这个for循环，则蛇全身都会变成蛇头~（好可怕）
		chess[i[0]][i[1]] = 3

# 修改（蛇走一步）场景（参数：蛇末尾的结点参数）
func _change_scene(pf: Array):
	# 删掉蛇末尾的格子（准确来说是body_point的开头）
	remove_rect(pf[1], pf[0])
	# 绘制一个蛇头
	draw_scene(snake_head[1], snake_head[0], 2)
	for i in body_point:
		# 重新在body_point里赋值3，如果不加这个for循环，则蛇全身都会变成蛇头~（好可怕）
		draw_scene(i[1], i[0], 3)

# 定义自定义延时，这里使用Global.speed进行设置，详见DifficultyScene.gd
# 当speed = 1时，该custom_interval = 2
# 当speed = 20时，该custom_interval = 0.1
var custom_interval = 20.0 / (Global.speed * 10)
# 定义自增时间
var time_accumulator = 0.0

# 每帧执行一次
func _process(delta: float) -> void:
	# 时间自增delta
	time_accumulator += delta
	# 如果自增时间超过了自定义时间，则执行一次execute_task。然后将自增时间重设为0
	if time_accumulator >= custom_interval:
		_execute_task()
		time_accumulator = 0.0

# 执行蛇走一遍
func _execute_task():
	# 给蛇的身体点位末尾添加一个蛇头，以方便蛇往前走一步。
	body_point.append(snake_head.duplicate(true))
	# 这里判断方向，如果是右，则执行，反之则往下
	if direction == 0:
		# 给snake_head的1结点+1
		snake_head[1] += 1
		# 如果蛇头大于60，则蛇头恢复成0
		if snake_head[1] >= 60:
			snake_head[1] = 0
	elif direction == 1:
		# 给蛇头的0结点+1，下同
		snake_head[0] += 1
		if snake_head[0] >= 40:
			snake_head[0] = 0
	elif direction == 2:
		snake_head[1] -= 1
		if snake_head[1] < 0:
			snake_head[1] = 59
	elif direction == 3:
		snake_head[0] -= 1
		if snake_head[0] < 0:
			snake_head[0] = 39
	# 获取蛇身体结点的最前面的数据
	var pf = body_point.front()
	# 如果蛇头当前位置不等于【食物】或者不等于【空】，则失败，输掉游戏。
	if chess[snake_head[0]][snake_head[1]] != 4 and chess[snake_head[0]][snake_head[1]] != 0:
		get_tree().change_scene_to_file("res://GameoverScene.tscn")
		return
	# 如果蛇头当前位置等于4，则分数+10，删掉snake_head当前色块。并重新生成一次食物。此时body_point不会删掉元素
	# 不会删除元素的意思就是，将蛇的长度+=1~
	elif chess[snake_head[0]][snake_head[1]] == 4:
		Global.score += 10
		remove_rect(snake_head[1], snake_head[0])
		_rand_food()
	# 如果等于空，则将蛇身体的最前面（蛇尾）的结点去掉，然后将最前面结点的值赋给pf。
	else:
		pf = body_point.pop_front()
	# 执行重新渲染蛇函数。首先将chess的值恢复，然后再仅渲染蛇的部位。
	_reload_snake(pf)
	_change_scene(pf)
	# 此处执行时开启输入
	is_dir = true

# 随机生成食物（当蛇的长度非常大时，可能会导致该函数异常慢）
func _rand_food():
	# 重复执行，直到找到一个可以生成食物的位置。
	while true:
		# i为0~40的随机数，j同理。
		var i = randi() % 40
		var j = randi() % 60
		if chess[i][j] == 0:
			# 如果该位置为空，则执行
			chess[i][j] = 4
			draw_scene(j, i, 4)
			break

# 初始化一次二维数组。
func initialize_2d_array(rows: int, columns: int, default_value):
	var array = []
	array.resize(rows)
	for i in range(rows):
		array[i] = []
		array[i].resize(columns)
		for j in range(columns):
			array[i][j] = default_value
	return array

# 将color的int数字，转换成float形式的数据并返回。
func color_int_to_float(r: int, g: int, b: int) -> Color:
	return Color(float(r) / 255, float(g) / 255, float(b) / 255)

# 渲染一个色块
func draw_scene(i: int, j: int, num: int):
	# 判断num
	match num:
		# 墙（橙色）
		1:
			# 首先必须执行一遍删除该色块，否则可能会出现蛇连续不断的生成色块，即使变量变成了null，但是色块的对象还留在程序里。
			remove_rect(i, j)
			# 然后再添加一次色块
			# Global.grid参见Global.gd
			add_rect(Vector2(i * Global.grid, j * Global.grid), Vector2(Global.grid, Global.grid), color_int_to_float(255, 178, 102), i, j)
		# 蛇头（深绿色）
		2:
			remove_rect(i, j)
			add_rect(Vector2(i * Global.grid, j * Global.grid), Vector2(Global.grid, Global.grid), color_int_to_float(0, 153, 0), i, j)
		# 蛇身（绿色）
		3:
			remove_rect(i, j)
			add_rect(Vector2(i * Global.grid, j * Global.grid), Vector2(Global.grid, Global.grid), color_int_to_float(0, 204, 0), i, j)
		# 食物（红色）
		4:
			remove_rect(i, j)
			add_rect(Vector2(i * Global.grid, j * Global.grid), Vector2(Global.grid, Global.grid), color_int_to_float(204, 0, 0), i, j)
		# 如果该地方是空，则移除一次色块（删除色块里有判断null的）
		_:
			remove_rect(i, j)

# 添加色块，第一个参数为位置，第二个参数为大小，第三个参数为颜色，第4、5个参数为当前执行到的scene位置。
func add_rect(pos: Vector2, size: Vector2, color: Color, i: int, j: int):
	scene_rect[j][i] = ColorRect.new()
	scene_rect[j][i].size = size
	scene_rect[j][i].color = color
	scene_rect[j][i].position = pos
	add_child(scene_rect[j][i])

func remove_rect(i: int, j: int):
	# 删除色块，先判断一次色块是否等于null。
	if scene_rect[j][i] != null:
		# 不等于null，执行删除色块操作
		remove_child(scene_rect[j][i])
		scene_rect[j][i].queue_free()
		scene_rect[j][i] = null
