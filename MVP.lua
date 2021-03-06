-----------------------------------------------------------------------------------------
--
-- MVP.lua
-- The list of all MVP winners.
--
-----------------------------------------------------------------------------------------
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

-- Called when the scene's view does not exist:

function scene:createScene( event )
    local group = self.view
	-- Insert a placeholder to work around a Storyboard API bug.
    local blah = display.newRetinaText( "blah", 18, 0, "Helvetica-Bold", 12 )
	group:insert( blah )
	blah.isVisible = false;
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )

	local group = self.view
	local widget = require "widget"
    currentScene = "MVP";

	local listOptions = {
        top = 44,
        height = 386,
        maskFile = "mask-386.png";
	}
 
	mvpList = widget.newTableView( listOptions )

	-- onEvent listener for the tableView
	local function onRowTouch( event )
        local row = event.target
        local rowGroup = event.view
 
        if event.phase == "press" then
            if not row.isCategory then rowGroup.alpha = 0.5;
               
            end
 
            elseif event.phase == "release" then
 
                if not row.isCategory then
                    updateHistory(currentScene);
                    -- reRender property tells row to refresh if still onScreen when content moves
                    row.reRender = true
                    local t
                    t = split(event.target.id);
                    whichPlayer = t[1]
                    print ("whichPlayer switched to: " .. whichPlayer);
               		-- Go to a particular player page
               			
                    storyboard.gotoScene( "player_page" );
                end
            end
 
 	        return true
	    end
 
    	-- onRender listener for the tableView that renders each row
	
	    local function onRowRender( event )
            local row = event.target
            local rowGroup = event.view
        
            -- Decompact id field
       
            local t
            t = split(event.target.id);
            local year = t[2]
            local compYear = year .. "-" .. computeNextSeason(year);
            local name = t[3]
   	 	
   	 	    local textDate = display.newRetinaText( compYear, 18, 0, "Helvetica-Bold", 18 )
    	    textDate:setReferencePoint( display.CenterLeftReferencePoint )
    	    textDate.y = row.height * 0.5
    	    local textName = display.newRetinaText(name, 18, 0, "Helvetica-Bold", 18);
    	    textName:setReferencePoint( display.CenterLeftReferencePoint )
    	    textName.y = row.height * 0.5
        
    	    if not row.isCategory then
    		    textDate.x = 10
    		    textDate:setTextColor( 100 )
    		
    		    textName.x = 120 ;
     		    textName:setTextColor(0);
    	    end
 
            -- Must insert everything into event.view: (tableView requirement)
            rowGroup:insert( textDate )
   		    rowGroup:insert(textName);
	    end
 
	    -- Create a row for each Player in the MVP list
	 
	    local playerFirstName;
        local playerLastName;
        local ilkid;
        local year;   
        local id;
        
        -- This is where you'll look up a player's name and stats
		
		for row in db:nrows("SELECT * FROM records_MVP ORDER BY year DESC") do

	        playerFirstName = row.firstname;
	        playerLastName = row.lastname;

	        ilkid = row.ilkid;
	        year = row.year;
	
	        id = ilkid .. "," .. year.. "," .. playerFirstName .. " " .. playerLastName;
   
            mvpList:insertRow{
                onEvent=onRowTouch,
                id=id,
                onRender=onRowRender,
                height=rowHeight,
                isCategory=isCategory,
                rowColor=rowColor,
                lineColor=lineColor
            }
	    end

	    -- all objects must be added to group (e.g. self.view) but are not in this case since widgets act problematically with group.insert
	    -- group:insert( list )
	    -- group:insert( title )

	    --create the NavBar with the appropriate title
	
	    createNavBar("MVPs");
        displayBackButton();
	    
	    --insert everything into the group to be changed on scene changes
        group:insert(navBar);
        group:insert(navHeader);
        group:insert(backButton)
    end

    -- Called when scene is about to move offscreen:

    function scene:exitScene( event )
	    local group = self.view
 	    mvpList:removeSelf()
  	    mvpList = nil
    end

    function scene:destroyScene( event )
	    local group = self.view
	end

-----------------------------------------------------------------------------------------
-- Don't touch below: Listeners needed for the Storyboard API.
-----------------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched whenever before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )

-----------------------------------------------------------------------------------------

return scene