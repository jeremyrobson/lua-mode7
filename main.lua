p = {x=0,y=0}
angle = 0.0
radians = 0.0
vel = 0.0
altitude = 50.0

function love.load()
    map = love.graphics.newImage("map1.png")
    canvas = love.graphics.newCanvas(256,256)
    quad = love.graphics.newQuad(0,0,256,256,256,256)
    
    shader = love.graphics.newShader([[
        extern Image map;
        extern vec2 p;
        extern float radians;
        extern float altitude;
        vec3 camera = vec3(0,0,0);
        float offset = 1.0;
        float zoom = 1.0;
        float startx = 0.0, starty = 0.0;
        float srcx = 0.0, srcy = 0.0;
        float line_dx = 0.0, line_dy = 0.0;
        float horizontal_scale = 0.0, horizon = 0.0, alpha = 1.0;
        float vel = 0.0;
        
        vec4 effect(vec4 color, Image tex, vec2 tc, vec2 sc) {
            //editable variables
            horizon = 0.3;
            offset = 1.0;
            zoom = 1.0;
            
            camera.x = p.x + cos(radians) * offset * zoom;
            camera.y = p.y + sin(radians) * offset * zoom;
            
            horizontal_scale = (altitude * zoom) / (tc.y - horizon * zoom);
            
            line_dx = -sin(radians) * horizontal_scale;
            line_dy = cos(radians) * horizontal_scale;
            
            startx = cos(radians) * horizontal_scale - 0.5*line_dx + camera.x; 
            starty = sin(radians) * horizontal_scale - 0.5*line_dy + camera.y;
            
            srcx = mod(startx + line_dx*tc.x,2048.0);
            srcy = mod(starty + line_dy*tc.x,2048.0);
            
            vec4 sky = vec4(0.0,0.0,0.0,0.0);
            alpha = 1.0;
            if (tc.y > horizontal_scale) {
                alpha = 0.0;
                sky = vec4(0.4,0.6,0.8,1.0);
            }
            
            vec4 c = Texel(map, vec2(srcx,srcy)/vec2(2048,2048));
            return vec4(c.r,c.g,c.b, alpha) + sky;
        }
    ]])
    
    shader:send("map", map)
end

function love.update(dt)
    if love.keyboard.isDown("left") then
        angle = angle - 0.005
    end
    if love.keyboard.isDown("right") then
        angle = angle + 0.005
    end
    if love.keyboard.isDown("up") then
        altitude = altitude + 1
    end
    if love.keyboard.isDown("down") then
        altitude = altitude - 1
    end
    if love.keyboard.isDown("z") then
        vel = 2.0
    else
        vel = 0.0
    end
    
    if angle < 0 then angle = 0.995 end
    if angle > 0.995 then angle = 0.005 end
    
    radians = angle * math.pi * 2
    
    p.x = p.x + vel * math.cos(radians)
    p.y = p.y + vel * math.sin(radians)
    
    p.x = p.x % 2048
    p.y = p.y % 2048
    
    shader:send("p",{p.x,p.y})
    shader:send("radians", radians)
    shader:send("altitude", altitude)
end

function love.draw()
    love.graphics.setShader(shader)
    
    love.graphics.setColor(255,255,255,255)
    love.graphics.draw(canvas,quad,0,0,0,2,2) 
    
    love.graphics.setShader()
end