#2-Player Snake
#Version 1.0
#by Razvan Ciuca

require 'gosu'
#
#      Main window. Contains drawing, game logic and keyboard inputs
#
class GameWindow < Gosu::Window
	def initialize
		super 660, 660, false, 80 #window size
		self.caption = "Badger Badger Badger Badger Badger Muuushrooom Muuuushrooom"
		@background = Gosu::Image.new(self, "#{$cwd}background.png", false)		
		@apple_image = Gosu::Image.new(self, "#{$cwd}apple2.png", false)		
		@reset = 0
		@tick = 0
		@snakes = []
		@snakes[0] = Snake.new(320,520,5,self,1) #make some snakesss
		@snakes[1] = Snake.new(320,120,5,self,2)
		@apple = Apple.new(@snakes.inject([]){|sum,snake| sum += snake.segments}) #make the first apple			
	end
	
												#Game logic
	def update
		if @reset == 1
			@snakes[0] = Snake.new(320,320,5,self,1) #make some snakesss
			@snakes[1] = Snake.new(320,120,5,self,2)
			@apple = Apple.new(@snakes.inject([]){|sum,snake| sum += snake.segments}) #make the first apple	
			@reset = 0
		end
		@tick += 1		
		@snakes.each do |snake|
			snake.move	
			snake.segments[0..-2].each do |segment|    #if snake runs into itself, that snake loses
				if snake.segments.last[0..1] == segment[0..1]
					snake.loses				
				end
			end
			if snake.segments.last[0..1] == [@apple.position[0],@apple.position[1]]  #if snake eats apple
				@apple = Apple.new(@snakes.inject([]){|sum,sn| sum += sn.segments})	 #generate new apple	
				snake.grow
				snake.update_score(1)
			end	
		end
	end	
												#Draw
	def draw		
		@snakes.each {|snake| snake.draw}		
		@apple_image.draw(@apple.position[0],@apple.position[1],1)
		@background.draw(0,0,0)		
	end
	
											#Keyboard inputs
	def button_down(id)		
		case id
			#Player 1 controls
			when Gosu::KbUp
				@snakes[0].turn('up',@tick)
			when Gosu::KbDown
				@snakes[0].turn('down',@tick)
			when Gosu::KbLeft
				@snakes[0].turn('left',@tick)
			when Gosu::KbRight
				@snakes[0].turn('right',@tick)	
			#Player 2 controls			
			when Gosu::KbW
				@snakes[1].turn('up',@tick)
			when Gosu::KbS
				@snakes[1].turn('down',@tick)
			when Gosu::KbA
				@snakes[1].turn('left',@tick)
			when Gosu::KbD
				@snakes[1].turn('right',@tick)	
			when Gosu::KbEscape
				close
			when Gosu::KbBackspace
				@reset = 1
		end
	end
end	
#
#       The snake. 
#
class Snake
	def initialize(sx,sy,size,window,player) #starting position of snake head
		@dx,@dy = -1,0				
		@body = generate_snake(sx,sy,@dx,size)
		@tickhold = 0	
		@facing = 'left'
		@target = 15  #target score
		@lost = false
		@score = 0
		@player = player
		@s = [[40,30],[500,30]] #score coordinates
		@l = [[263,355],[263,265]] #lose message coordinates
		@w = [[230,355],[230,265]] #win message coordinates
		@score_image = Gosu::Font.new(window,Gosu::default_font_name,25)
		@lose = Gosu::Font.new(window,Gosu::default_font_name,25)
		@bodyh = Gosu::Image.new(window, "#{$cwd}bodyh.png", false)
		@bodyv = Gosu::Image.new(window, "#{$cwd}bodyv.png", false)
		@upleft = Gosu::Image.new(window, "#{$cwd}upleft.png", false)
		@upright = Gosu::Image.new(window, "#{$cwd}upright.png", false)
		@downleft = Gosu::Image.new(window, "#{$cwd}downleft.png", false)
		@downright = Gosu::Image.new(window, "#{$cwd}downright.png", false)
		@tailleft = Gosu::Image.new(window, "#{$cwd}tailleft.png", false)
		@tailright = Gosu::Image.new(window, "#{$cwd}tailright.png", false)
		@tailup = Gosu::Image.new(window, "#{$cwd}tailup.png", false)
		@taildown = Gosu::Image.new(window, "#{$cwd}taildown.png", false)
		@head = Gosu::Image.new(window, "#{$cwd}head.png", false)
		@again = Gosu::Font.new(window,Gosu::default_font_name,40)
	end
	
	def move		
		@tail = @body.shift #remove a tail piece
		hx,hy = @body.last[0],@body.last[1] #head coordinates			
		case [@dx,@dy]  #storing the facing direction of the block for tail drawing purposes
			when [1,0]
				@facing = 'right'
			when [0,1]
				@facing = 'down'
			when [-1,0]
				@facing = 'left'
			when [0,-1]
				@facing = 'up'
		end
		new = [hx+20*@dx,hy+20*@dy,@facing]			
		if new[0] == 0   #dealing with running into a wall
			new[0] = 620 
		elsif new[0] == 640
			new[0] = 20
		end		
		if new[1] == 0
			new[1] = 620 
		elsif new[1] == 640
			new[1] = 20
		end		
		
		@body << new 		
	end
	
	def draw
		if @lost  #draw losing screen		
			@lose.draw("Player #{@player} lost!",@l[@player-1][0],@l[@player-1][1],2,1.0, 1.0, 0xf0000000)				
		end
		if @score >= @target  #draw winning screen
			@lose.draw("A winnar is Player #{@player}!",@w[@player-1][0],@w[@player-1][1],2,1.0, 1.0, 0xf0000000)	
			@again.draw("Press BACKSPACE to play again",60,300,3,1,1,0xf0000000)
		end
		@score_image.draw("Player #{@player}: #{@score}",@s[@player-1][0],@s[@player-1][1],2,1,1,0x80808080)
		tail = @body.first  #draw tail
		case tail[2]
			when "left"
				@tailleft.draw(tail[0],tail[1],1) 
			when "up"
				@tailup.draw(tail[0],tail[1],1) 
			when "right"
				@tailright.draw(tail[0],tail[1],1) 
			when "down"
				@taildown.draw(tail[0],tail[1],1) 
		end
		@body[1..-2].each do |segment|  #draw body
			case segment[2]
				when "upleft"
					@upleft.draw(segment[0],segment[1],1) 
				when "upright"
					@upright.draw(segment[0],segment[1],1) 
				when "downright"
					@downright.draw(segment[0],segment[1],1) 
				when "downleft"
					@downleft.draw(segment[0],segment[1],1) 
				when "left","right"
					@bodyh.draw(segment[0],segment[1],1) 
				when "up","down"
					@bodyv.draw(segment[0],segment[1],1) 				
			end			
		end
		head = @body.last #draw head
		case [@dx,@dy]
			when [1,0]
				@head.draw_rot(head[0],head[1],1,0,0,0)
			when [0,-1] 
				@head.draw_rot(head[0],head[1],1,270,1,0)
			when [-1,0] 
				@head.draw_rot(head[0],head[1],1,180,1,1)
			when [0,1] 
				@head.draw_rot(head[0],head[1],1,90,0,1)
		end
	end
	
	def grow		
		@body.unshift(@tail)			
	end
	
	def turn(dir,tick)
		if tick > @tickhold  #check if we have already made a turn during this tick
			dir = convert(dir)					
			if dir != [@dx,@dy] && dir != [-@dx,-@dy]
				case [@dx,@dy]+dir   #track facing direction for turn segments
					when [-1,0,0,-1],[0,1,1,0]
						@facing = "upright"
					when [0,-1,1,0],[-1,0,0,1]
						@facing = "downright"
					when [1,0,0,1],[0,-1,-1,0]
						@facing = "downleft"
					when [1,0,0,-1],[0,1,-1,0]
						@facing = "upleft"
				end				
				@body[-1][2] = @facing
				@dx,@dy = dir[0],dir[1]
				@tickhold = tick
			end			
		end
	end
	
	def segments
		return @body
	end
	
	def update_score(x)
		@score += x
	end
	
	def loses
		@lost = true
	end
end

def generate_snake(sx,sy,dx,size)
	#snake is generated with head at sx,sy, with size segments at the right of the head
	body = [[sx,sy,"left"]]
	for i in 1..size-1
		body << [sx-i*20*dx,sy,"left"]
	end
	return body.reverse
end

def convert(direction)
	case direction
		when "left" 
			return [-1,0]
		when "right" 
			return [1,0]
		when "up"
			return [0,-1]
		when "down"
			return [0,1]
	end
end

class Apple
	def initialize(body)
		@x=20*(rand(31)+1)
		@y=20*(rand(31)+1)	
		while body.transpose[0..1].transpose.include?([@x,@y]) #there must be an easier way to do this...
			@x=20*(rand(31)+1)
			@y=20*(rand(31)+1)
		end
	end
	def position
		return [@x,@y]
	end
end

#Main
$cwd = $0[0..-14]
#$cwd = $0[0..-(__FILE__.length + 1)]
window = GameWindow.new
window.show