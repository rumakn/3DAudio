classdef maze
    
      properties
        IndexI = 5;
        IndexJ = 3;
        SoundIndexI = 5;
        SoundIndexJ = 3;
        Walls = maze.init();
        
        
        maxX = 0.682;
        maxY = 0.610;
        
        
        PlayerXPos = 5;
        PlayerYPos = 3;
        intervalX = 0;
        intervalY = 0;
        
        
        
        
      end
    
      
    methods (Static)  
       function Ma = init()
   
            Ma(5,5) = Cell;

            %define the border
            Ma(1,1).left = 1;
            Ma(2,1).left = 1;
            Ma(3,1).left = 1;
            Ma(4,1).left = 1;
            Ma(5,1).left = 1;
            
            Ma(1,5).right = 1;
            Ma(2,5).right = 1;
            Ma(3,5).right = 1;
            Ma(4,5).right = 1;
            Ma(5,5).right = 1;
            
            
            Ma(1,1).top = 1;
            Ma(1,2).top = 1;
            Ma(1,4).top = 1;
            Ma(1,5).top = 1;
            
            Ma(5,1).bottom = 1;
            Ma(5,2).bottom = 1;
            Ma(5,4).bottom = 1;
            Ma(5,5).bottom = 1;

            %define the walls
            Ma(1,1).left = 1;
            Ma(1,2).bottom = 1;
            Ma(1,3).bottom = 1;
            Ma(1,4).right = 1;
            Ma(1,5).left = 1;
            
            
            Ma(2,1).bottom = 1;
            Ma(2,2).top = 1;
            Ma(2,2).bottom = 1;
            Ma(2,3).top = 1;
            Ma(2,3).right = 1;
            Ma(2,4).left = 1;
            Ma(2,4).bottom = 1;
            
            
            Ma(3,1).top = 1;
            Ma(3,2).top = 1;
            Ma(3,2).right = 1;
            Ma(3,2).bottom = 1;
            Ma(3,3).left = 1;
            Ma(3,4).top = 1;
            Ma(3,4).right = 1;
            Ma(3,5).left = 1;
            
            
            Ma(4,1).right = 1;
            Ma(4,2).left = 1;
            Ma(4,2).top = 1;
            Ma(4,3).bottom = 1;
            Ma(4,3).right = 1;
            Ma(4,4).left = 1;
            Ma(4,4).right = 1;
            Ma(4,5).left = 1;
            
            
            Ma(5,2).right = 1;
            Ma(5,3).left = 1;
            Ma(5,3).top = 1;
            Ma(5,4).right = 1;
            Ma(5,5).left = 1;
       end
        
       function WallRet = showPos(p)
           %disp(p.IndexI);
           %disp(p.IndexJ);
           WallRet = [0;0;0;0]
           WallRet(1) = p.Walls(p.IndexI , p.IndexJ).left;
           WallRet(2) = p.Walls(p.IndexI , p.IndexJ).right;
           WallRet(3) = p.Walls(p.IndexI , p.IndexJ).top;
           WallRet(4) = p.Walls(p.IndexI , p.IndexJ).bottom;
       end
       
       function wallB = checkWallLeft(p)
           %disp(p.IndexI); disp(p.IndexJ);
           if p.Walls(p.IndexI , p.IndexJ).left
               wallB = false;
           else
               wallB = true;
           end
       end
       
       
       function wallB = checkWallRight(p)
           if p.Walls(p.IndexI , p.IndexJ).right
               wallB = false;
           else
               wallB = true;
           end
       end
           
       
        function wallB = checkWallTop(p)
           if p.Walls(p.IndexI , p.IndexJ).top
               wallB = false;
           else
               wallB = true;
           end
        end
       
         function wallB = checkWallBottom(p)
           if p.Walls(p.IndexI , p.IndexJ).bottom
               wallB = false;
           else
               wallB = true;
           end
         end
         function ret = setSize(p , wid, hei)
             p.maxX = wid;
             p.maxY = hei;
             p.intervalX = wid/5;
             p.intervalY = hei/5;
             ret = p;
         end
         
         function value = convertX(p,val)
             val=val *.57/p.maxX;
             val = val +.18;
             value = val;
         end
         
          function value = convertY(p,val)
             val=val *.62/p.maxY;
             val = val +.18;
             value = val;
         end
         
         
    end
end