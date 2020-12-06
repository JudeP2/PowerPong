push = require 'push'


Class = require 'class'


require 'Paddle'


require 'Ball'


WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720


VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243


PADDLE1_SPEED = 200
PADDLE2_SPEED = 200
paddle_height = 20


function love.load()

    
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- sets title to pong on the window
    love.window.setTitle('Pong')

    -- makes random calls completely random
    math.randomseed(os.time())

    

    -- different sizes for font such as score or titles
    powerFont = love.graphics.newFont('font.ttf', 8)
    smallFont = love.graphics.newFont('font.ttf', 8.5)
    largeFont = love.graphics.newFont('font.ttf', 16)
    scoreFont = love.graphics.newFont('font.ttf', 32)
    love.graphics.setFont(smallFont)

    -- gives sound effects a name so they can be called for specific purposes
    sounds = {
        ['paddle_hit'] = love.audio.newSource('paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('wall_hit.wav', 'static'),
        ['powerup'] = love.audio.newSource('powerup.wav', 'static'),
        ['gamemusic']= love.audio.newSource('gamemusic.wav', 'static'),
        -- game music by Jammerboy70 on freesound.org: https://freesound.org/people/jammerboy70/sounds/398640/
        ['victory']= love.audio.newSource('victory.wav', 'static')
    }
    
    -- resolution of the game screen
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true,
        canvas = false
    })

    -- creates the specific left and right paddles
    player1 = Paddle(10, 30, 5, paddle_height)
    player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)

    -- place a ball in the middle of the screen
    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    -- set score to zero so it can go up depending on who scores
    player1Score = 0
    player2Score = 0

   -- determines where the ball will go first
    servingPlayer = 1

    -- determines who wins which will then 
    -- prompt the user to press enter if they wish to restart
    winningPlayer = 0

    
    gameState = 'start'
end


function love.resize(w, h)
    push:resize(w, h)
end


function love.update(dt)
    if gameState =='start' then
        sounds['gamemusic']:play()
    end

    if gameState == 'serve' then
        -- sends ball to player depending on who scored last
        ball.dy = math.random(-50, 50)
        if servingPlayer == 1 then
            ball.dx = math.random(140, 200)
        else
            ball.dx = -math.random(140, 200)
        end
    elseif gameState == 'play' then
        -- reverses the velocity of the ball if a player collides the paddle with it
        if ball:collides(player1) then
            ball.dx = -ball.dx * 1.03
            ball.x = player1.x + 5

            -- keeps velocity going in the same direction, but will randomize it
            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end

            sounds['paddle_hit']:play()
            
        end
        if ball:collides(player2) then
            ball.dx = -ball.dx * 1.03
            ball.x = player2.x - 4

            -- keeps velocity going in the same direction, but will randomize it
            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end

            sounds['paddle_hit']:play()
        end

        -- if the ball hits the top or bottom 
        -- of the screen it will bounce off as well as play a sound effect
        if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end

        
        if ball.y >= VIRTUAL_HEIGHT - 4 then
            ball.y = VIRTUAL_HEIGHT - 4
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end

        -- if the ball goes past the right or 
        -- left of the screen a point is given accordingly
        if ball.x < 0 then
            servingPlayer = 1
            player2Score = player2Score + 1
            sounds['score']:play()

            -- 10 is the max score which then puts the game into the victory state
            if player2Score == 10 then
                winningPlayer = 2
                sounds['victory']:play()
                gameState = 'done'
                
            else
                gameState = 'serve'
                -- resets the ball to the middle with no velocity
                ball:reset()
            end
        end
       

        if ball.x > VIRTUAL_WIDTH then
            servingPlayer = 2
            player1Score = player1Score + 1
            sounds['score']:play()

            if player1Score == 10 then
                winningPlayer = 1
                sounds['victory']:play()
                gameState = 'done'
                
            else
                gameState = 'serve'
                ball:reset()
            end
        end
    end

    --
   
    --
    -- player 1's movement
    if love.keyboard.isDown('w') then
        player1.dy = -PADDLE1_SPEED
    elseif love.keyboard.isDown('s') then
        player1.dy = PADDLE1_SPEED
    else
        player1.dy = 0
    end

    -- player 2's movement
    if love.keyboard.isDown('up') then
        player2.dy = -PADDLE2_SPEED
    elseif love.keyboard.isDown('down') then
        player2.dy = PADDLE2_SPEED
    else
        player2.dy = 0
    end

    
    if gameState == 'play' then
        ball:update(dt)
    end

    player1:update(dt)
    player2:update(dt)
end


function love.keypressed(key)
    
    if key == 'escape' then
        -- pressing escape closes the window
        love.event.quit()
    -- pressing enter serves the ball
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'done' then
            
            gameState = 'serve'

            ball:reset()

            -- reset player scores to 0
            player1Score = 0
            player2Score = 0

            -- decide serving player as player who lost last game
            if winningPlayer == 1 then
                servingPlayer = 2
            else
                servingPlayer = 1
            end
        end
    end
end


function love.draw()
    
    push:start()

    love.graphics.clear(40/255, 45/255, 52/255, 255/255)
    
    -- renders text on the screen for specific purposes like score and powerups
    if gameState == 'start' then
        -- UI messages
        love.graphics.setFont(smallFont)
        love.graphics.setColor(255, 255, 255,255)
        love.graphics.printf('Welcome to PowerPong!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to begin!', 0, 130, VIRTUAL_WIDTH, 'center')
        
    elseif gameState == 'serve' then
        -- UI messages
        love.graphics.setFont(smallFont)
        love.graphics.setColor(255, 255, 255,255)
        love.graphics.printf('Player ' .. tostring(servingPlayer) .. "'s serve!", 
            0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to serve!', 0, 130, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'play' then
        -- no UI messages to display in play
    elseif gameState == 'done' then
        -- UI messages
        love.graphics.setFont(largeFont)
        love.graphics.setColor(0, 255/255, 0, 200/255)
        love.graphics.printf('Player ' .. tostring(winningPlayer) .. ' wins!',
            0, 60, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press Enter to restart!', 0, 130, VIRTUAL_WIDTH, 'center')
    end
   
    
    displayScore(love.graphics.setColor(255, 255, 255, 255))
    
    player1:render(love.graphics.setColor(255, 255, 255,255))
    player2:render(love.graphics.setColor(255, 255, 255,255))
    ball:render(love.graphics.setColor(25, 255, 255,255))

    -- displays FPS 
    displayFPS()

     -- powerup 1: paddle speed buff(Jude Piacentino)
     -- player 1 paddle speed increase
    

    if player1Score <= player2Score - 2 then
        PADDLE1_SPEED = 300
        love.graphics.setFont(powerFont)
        love.graphics.setColor(0, 255, 255,255)
        love.graphics.printf('Player 1 has Paddle speed Powerup!', 0, 30, VIRTUAL_WIDTH, 'center')
    
    
    -- sets back to normal if scores are even
    elseif player1Score == player2Score then
        PADDLE1_SPEED = 200
        love.graphics.setColor(255, 0, 255,255)
        love.graphics.printf('Score even! No powerups at play!', 0, 30, VIRTUAL_WIDTH, 'center')
    end
    -- powerup 1: paddle speed buff(Jude Piacentino)
    -- player 2 paddle speed increase
    if player2Score <= player1Score - 2 then
        PADDLE2_SPEED = 300
        
        love.graphics.setFont(powerFont)
        love.graphics.setColor(0, 255, 255,255)
        love.graphics.printf('Player 2 has Paddle speed Powerup!', 0, 30, VIRTUAL_WIDTH, 'center')
        
        -- sets back to normal if scores are even
    elseif player2Score >= player1Score then
        PADDLE2_SPEED = 200
    elseif player2Score == player1Score then
        love.graphics.setColor(255, 0, 255,255)
        love.graphics.printf('Score even! No powerups at play!', 0, 30, VIRTUAL_WIDTH, 'center')
    end
        --handicap/debuff 1 paddle speed (Jude Piacentino)
        -- player 2 paddle speed lowered for player 1 handicap
    if player1Score <= player2Score - 5 then
        PADDLE2_SPEED = 150
        love.graphics.setColor(255, 0, 0,255)
        love.graphics.printf('Player 2 paddle speed is decreased!', 0, 40, VIRTUAL_WIDTH, 'center')
    elseif player1Score == player2Score then
        PADDLE2_SPEED = 200
    end
        --handicap/debuff 1 paddle speed (Jude Piacentino)
        -- player 1 paddle speed lowered for player 2 handicap
    if player2Score <= player1Score - 5 then
        PADDLE1_SPEED = 150
        love.graphics.setColor(255, 0, 0,255)
        love.graphics.printf('Player 1 paddle speed is decreased!', 0, 40, VIRTUAL_WIDTH, 'center')
    elseif player2Score == player1Score then
        PADDLE1_SPEED = 200
        
    end

    
    -- Handicap 2: extra 5 points if losing player scores while down by 9 points
    -- (therefore only can occur once when its 0-9)
    if player1Score <= player2Score - 6 then
        love.graphics.setColor(255, 0, 0,200)
        love.graphics.printf('Player 1 can gain 5 points if they score!', 0, 50, VIRTUAL_WIDTH, 'center')
        if ball.x > VIRTUAL_WIDTH then
            servingPlayer = 2
            player1Score = player1Score + 4
            sounds['score']:play()
        end
    elseif player1Score == player2Score then
        if ball.x > VIRTUAL_WIDTH then
            love.graphics.setColor(255, 0, 0,255)
            servingPlayer = 2
            player1Score = player1Score + 0
            sounds['score']:play()
        end
        
    end
    
    if player2Score <= player1Score - 6 then
        
        love.graphics.setColor(255, 0, 0,255)
        love.graphics.printf('Player 2 can gain 5 points if they score!', 0, 50, VIRTUAL_WIDTH, 'center')
        if ball.x < 0 then
            servingPlayer = 1
            player2Score = player2Score + 4
            sounds['score']:play()
        end
    elseif player2Score == player1Score then
        if ball.x < 0 then
            servingPlayer = 1
            player2Score = player2Score + 0
            sounds['score']:play()
        end
        
    end
   
    
    push:finish()
end


function displayScore()
    -- score display
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50,
        VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30,
        VIRTUAL_HEIGHT / 3)
end


function displayFPS()
    -- simple FPS display
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 255/255, 0, 255/255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
    love.graphics.setColor(255, 255, 255, 255)
end