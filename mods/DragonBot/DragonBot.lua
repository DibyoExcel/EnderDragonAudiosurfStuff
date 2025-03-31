function fif(test, if_true, if_false)
  if test then return if_true else return if_false end
end

calcAntiJumps = false
randomizeblocktypes = false
percentGrey = 0
shoulderlanes = false

GameplaySettings{
		maxstrafe = fif(shoulderlanes, 6, 3),
		rightsticksteering = true,

		usepuzzlegrid = false,
		puzzlerows = 0,
		puzzlecols = 0,
        greypercent=percentGrey,
        railedblockscanbegrey = true,
        --colorcount=2,
        colorcount=1,
        usetraffic = true,
        automatic_traffic_collisions = false, -- the game shouldn't check for block collisions since we'll be doing that ourselves in this script
        jumpmode="none",
        matchcollectionseconds=1.5,
        --greyaction="eraseone", -- "eraseall"  -- "eraseblock"
        greyaction="eraseall",
        trafficcompression=0.69,

		--track generation settings
		gravity=-.45, -- even without jumping the gravity setting is (a little bit) relevant. It's used in generating the track to sculpt it steep enough to allow jumps
        playerminspeed = 0,--so the player is always moving somewhat
        playermaxspeed = 5.0,--2.5
        minimumbestjumptime = 2.5,--massage the track until a jump of at least this duration is possible
        uphilltiltscaler = 3.5,--set to 1 for normal track. higher for steeper
        downhilltiltscaler = 3.5,--set to 1 for normal track. higher for steeper
        uphilltiltsmoother = 0.025,
        downhilltiltsmoother = 0.05,
        useadvancedsteepalgorithm = true,--set false for a less extreme track
        alldownhill = false,
        puzzleblockfallinterval = .1,
        blockflight_secondstopuzzle = .25,
        calculate_antijumps_and_antitraffic = calcAntiJumps -- build a track that goes down/faster during calm parts of the music to find "anti jumps" and "anti traffic"
		--end track generation settings
}

SetSkinProperties{
	lanedividers={-1.5,1.5},
	shoulderlines={-4.5,4.5},
	trackwidth = fif(shoulderlanes, 8, 5),
	prefersteep = true
}

player={
	score=0,
	prevInput={},
	iPrevRing=0,
	hasFinishedScoringPrevRing=false,
	uniqueName = "Player",
	num=1,
	prevFirstBlockCollisionTested = 1,
	pos = {0,0,0},
	posCosmetic = {0,0,1.5},
	controller = "mouse",
	points = 0 -- used for accumulating points this player earns at each match collection. temp var
}

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function CompareJumpTimes(a,b) --used to sort the track nodes by jump duration
	return a.jumpairtime > b.jumpairtime
end

function CompareAntiJumpTimes(a,b) --used to sort the track nodes by jump duration
	return a.antiairtime > b.antiairtime
end

powernodes = powernodes or {}
antinodes = antinodes or {}
lowestaltitude = 9999
highestaltitude = -9999
lowestaltitude_node = 0
highestaltitude_node = 0
--onTrackCreatedHasBeenCalled = false
longestJump = longestJump or -1



track = track or {}
function OnTrackCreated(theTrack)--track is created before the traffic
	--onTrackCreatedHasBeenCalled = true
	track = theTrack

	local songMinutes = track[#track].seconds / 60

	for i=1,#track do
		track[i].jumpedOver = false -- if this node was jumped over by a higher proiority jump
		track[i].origIndex = i
		track[i].antiOver = false
	end

	--find the best jumps path in this song
	local strack = deepcopy(track)
	table.sort(strack, CompareJumpTimes)

	print("POWERNODE calculations. Best air time "..strack[1].jumpairtime)

	for i=1,#strack do
--		if strack[i].origIndex > 300 then
		if strack[i].jumpairtime >= 2.4 then --only consider jumps of at least this amount of air time
			longestJump = math.max(longestJump, strack[i].jumpairtime)
			--print("POWERNODE airtime"..strack[i].jumpairtime)
			if not track[strack[i].origIndex].jumpedOver then
				local flightPathClear = true
				local jumpEndSeconds = strack[i].seconds + strack[i].jumpairtime + 10
				for j=strack[i].origIndex, #track do --make sure a higher priority jump doesn't happen while this one would be airborne
					if track[j].seconds <= jumpEndSeconds then
						if track[j].jumpedOver then
							flightPathClear = false
						end
					else
						break
					end
				end
				if flightPathClear then
					if #powernodes < (songMinutes + 2) then -- allow about one power node per minute of music
						if strack[i].origIndex > 300 then
							powernodes[#powernodes+1] = strack[i].origIndex
							print("added powernode at ring "..strack[i].origIndex)
						end
						local extraJumpOverBufferSec = 10
						jumpEndSeconds = strack[i].seconds + strack[i].jumpairtime + extraJumpOverBufferSec
						for j=strack[i].origIndex, #track do
							if track[j].seconds <= jumpEndSeconds then
								track[j].jumpedOver = true --mark this node as jumped over (a better jump took priority) so it is not marked as a powernode
							else
								break
							end
						end
					end
				end
			end
		end

		if strack[i].pos.y > highestaltitude then
			highestaltitude = strack[i].pos.y
			highestaltitude_node = i
		end
		if strack[i].pos.y < lowestaltitude then
			lowestaltitude = strack[i].pos.y
			lowestaltitude_node = i
		end
	end

--	print("ontrackcreated. num powernodes "..#powernodes)
end

function CompareTrafficStrengthASC(a,b)
	return a.strength < b.strength
end

function CompareTrafficSpanDESC(a,b)
	return a.span > b.span
end

function CompareTrafficOrigIndexASC(a,b)
	return a.origIndex < b.origIndex
end

lanespace = 3
half_lanespace = 1.5

blocks = blocks or {}
blockNodes = blockNodes or {}
blockOffsets = blockOffsets or {}
--blockColors = blockColors or {}
traffic = traffic or {}

blockCount = 0
blocksCollected = 0
blocksMissed = 0

function OnTrafficCreated(theTraffic)
	half_lanespace = lanespace / 2

	traffic = theTraffic

	--print("OnTrafficCreated OnTrackCreatedHasBeenCalled:"..fif(onTrackCreatedHasBeenCalled, "true", "false"))

	local minimapMarkers = {}
	for j=1,#powernodes do --insert powernodes into the traffic
		local prev = 2
		for i=prev, #traffic do
			--if traffic[i].impactnode >= powernodes[j] then
			if traffic[i].chainend >= powernodes[j] then
				--if traffic[i].impactnode == powernodes[j] then
				if traffic[i].chainstart <= powernodes[j] then
					traffic[i].powerupname = "powerpellet"
					traffic[i].type = 101 -- replace the block already at this node with a power pellet. 101 as a type doesn't mean anything to the game, but the script uses it
					traffic[i].powerRating = j
				else
					table.insert(traffic, i, {powerupname="powerpellet", type=101, impactnode=powernodes[j], chainstart=powernodes[j], chainend=powernodes[j], lane=0, strafe=0, strength=10, powerRating=j})
				end
				prev = i

				table.insert(minimapMarkers, {tracknode=powernodes[j], startheight=0, endheight=fif(j==1, 15, 11), color=fif(j==1, {233,233,233}, nil) })
				break
			end
		end
	end

	AddMinimapMarkers(minimapMarkers)

	if calcAntiJumps then
		for j=1,#antinodes do --insert antipowernodes into the traffic
			local prev = 2
			for i=prev, #traffic do
				--if traffic[i].impactnode >= powernodes[j] then
				if traffic[i].chainend >= antinodes[j] then
					--if traffic[i].impactnode == powernodes[j] then
					if traffic[i].chainstart <= antinodes[j] then
						traffic[i].powerupname = "powerpellet"
						traffic[i].type = 101 -- replace the block already at this node with a power pellet. 101 as a type doesn't mean anything to the game, but the script uses it
						traffic[i].powerRating = j
					else
						table.insert(traffic, i, {powerupname="powerpellet", type=101, impactnode=antinodes[j], chainstart=antinodes[j], chainend=antinodes[j], lane=0, strafe=0, strength=10, powerRating=j})
					end
					prev = i

					break
				end
			end
		end
	end

	--fix most troll PBs by extending the front of the PBs chainspan
    for i = 2, #traffic do
    	if traffic[i].type == 101 then
    		local prevBlock = traffic[i-1]
    		local prevBlockChainEndSeconds = track[prevBlock.chainend].seconds
    		if (track[traffic[i].chainstart].seconds - track[prevBlock.chainend].seconds) > 1.3 then
    			for j=traffic[i].chainstart, prevBlock.chainend, -1 do
    				if track[j].seconds - prevBlockChainEndSeconds < 1.3 then
    					if (traffic[i].chainstart - j) < 100 then
    						traffic[i].chainstart = j
    					end
    					break;
    				end
    			end
    		end
    	end
    end

	math.randomseed(GetMillisecondsSinceStartup()) --randomize traffic lanes so it is different every time even for the same song
	--math.randomseed(1111) --static seed so it is same every time  (no random lanes)

	local blockIndex = 1

	if not randomizeblocktypes then -- don't randomize. Instead, take the longest chains and the weakest blocks and make them grey
		for i=1,#traffic do
			traffic[i].origIndex = i
			traffic[i].span = traffic[i].chainend - traffic[i].chainstart

	    	if(traffic[i].type < 100) then --keep the powerups where they were already calculated
	    		traffic[i].type = 6 -- first, set all blocks to color
	    	end
		end

		table.sort(traffic, CompareTrafficStrengthASC)
		local bound = math.floor(#traffic * percentGrey)
		for i=1, bound do
			if(traffic[i].type < 100) then --keep the powerups where they were already calculated
				traffic[i].type = 5 --set weakest blocks grey
			end
		end

--		table.sort(traffic, CompareTrafficSpanDESC)
--		bound = math.floor(#traffic * .05)
--		for i=1, bound do
--			if(traffic[i].type < 100) then --keep the powerups where they were already calculated
--				traffic[i].type = 5 --set longest block chains to grey
--			end
--		end

		table.sort(traffic, CompareTrafficOrigIndexASC) -- return traffic to normal order
	end

    for i = 1, #traffic do
    	local lane = math.random(-1,1)
    	if traffic[i].type >= 100 then
    		lane = 0 -- powerups default to the center lane
    	end
    	traffic[i].lane = lane

    	--make sure powerups don't overlap with any chainspans
    	if traffic[i].type >=100 then
    		local powerupImpactNode = traffic[i].impactnode
    		local powerupLane = traffic[i].lane
    		for k=1,#traffic do
    			if (traffic[k].chainstart <= powerupImpactNode) and (traffic[k].chainend >= powerupImpactNode) and (traffic[k].type < 100) then
    				while traffic[k].lane == powerupLane do
    					traffic[k].lane = math.random(-1,1)
    				end
    			end
    		end
    	end

    	local strafe = traffic[i].lane * lanespace
    	traffic[i].strafe = strafe
    	local offset = {strafe,0,0}

    	local span = traffic[i].chainend - traffic[i].chainstart
    	local caterpillarstart = traffic[i].impactnode;
    	local caterpillarend = traffic[i].impactnode;
    	local iscaterp = false
--    	if traffic[i].type==5 and (span>0) then
--    		caterpillarstart = traffic[i].chainstart
--    		caterpillarend = traffic[i].chainend
--    		iscaterp = true
--    	end

    	for j=caterpillarstart, caterpillarend do --build out grey caterpillars as block chains
			--local block = {}
			local block = deepcopy(traffic[i])
			if iscaterp then
				block.impactnode = j
				block.chainstart = block.impactnode
				block.chainend = block.impactnode
			end

			if (not iscaterp) or (j==caterpillarstart) or (j==caterpillarend) or (j%3==0) then --sparse caterpillars to keep the block count down
				block.lane = traffic[i].lane
				block.hidden = false
				--block.tested = false
				block.irrelevant = false
				block.collisiontestcount = 0
				--for j=1,#players do
				--	block.tested[j] = false --each player must collision test each block seperately since players can (sometimes) collide with the same blocks as each other
				--end
	--			block.type = traffic[i].type
				block.seconds = track[block.impactnode].seconds


				block.trackedscales = {
					{nodestoimpact=-1, scale={.75,.75,.75}},
					{nodestoimpact=1, scale={1.75,1.75,1.75}},
					{nodestoimpact=5, scale={1,1,1}}
				}


	--			block.impactnode = traffic[i].impactnode
				block.index = blockIndex
				blocks[#blocks+1]=block
				--astroidLanes[#astroidLanes+1] = lane
				blockNodes[#blockNodes+1] = block.impactnode
				blockOffsets[#blockOffsets+1] = offset
				--blockColors[#blockColors+1] = track[traffic[i].impactnode].color

				blockIndex = blockIndex+1
			end
    	end
    end

    local minnodespace = 4 --blocks of different types need to be at least this number of nodes away if they're in the same lane
    local minsecspace = 0.15 --blocks of different types need to be at least this amount of seconds away if they're in the same lane
    local prevtype = blocks[1].type
    local prevlane = blocks[1].lane
    local prevseconds = blocks[1].seconds
    local prevnode = blocks[1].impactnode
    for i=1, #blocks do
    	local block = deepcopy(blocks[i])
    	local secspan = block.seconds-prevseconds
    	if ((block.impactnode-prevnode) < minnodespace) or (secspan < minsecspace) then
    		--this block is very close with the one behind it
    		if block.type ~= prevtype then
    			--they're not the same type, so make sure they're not in the same lane
    			while block.lane == prevlane do
    				block.lane = math.random(-1,1)
    			end
    		else
    			--they're the same type, so make sure they're in the same lane if they're very close together
    			if secspan < 0.2 then -- these blocks are very close together, make sure they not spread across the 2 outside lanes
    				if (block.lane==-1 and prevlane==1) or (block.lane==1 and prevlane==-1) then
    					block.lane = 0
    				end
    				--block.lane = prevlane
    			end
    		end
    	end
    	local strafe = block.lane * lanespace
    	block.strafe = strafe
    	local offset = {strafe,0,0}

    	blocks[i] = block
    	blockOffsets[i] = offset

    	prevtype = block.type
    	prevlane = block.lane
    	prevseconds = block.seconds
    	prevnode = block.impactnode
    end

    local tabooLane = 0
    for i=1,#blocks do
    	if blocks[i].type==5 then
		    while blocks[i].lane == tabooLane do
				blocks[i].lane = math.random(-1,1)
			end
    		blocks[i].strafe = blocks[i].lane * lanespace
    		blockOffsets[i] = {blocks[i].strafe,0,0}
    	else
    		tabooLane= blocks[i].lane
    	end
    end

    blockCount = #blocks

    return blocks--traffic -- when you return a traffic table from this function the game will read and apply any changes you made
end

function InsertLoopyLoop(theTrack, apexNode, circumference)
	circumference = math.floor(circumference)
	apexNode = math.floor(apexNode)
    local halfSize = math.floor(circumference / 2)

    if (apexNode < halfSize) or ((apexNode + halfSize) > #theTrack) then
    	return theTrack
    end

    local startRing = math.max(1,apexNode - halfSize)
    local endRing = math.min(#theTrack, apexNode + halfSize)
    local span = endRing - startRing
    local startTilt = theTrack[startRing].tilt
    local endOriginalTilt = theTrack[endRing].tilt
    local endOriginalPan = theTrack[endRing].pan
    local tiltDeltaOverEntireLoop = -360 + (endOriginalTilt - startTilt)
    local startPan = theTrack[startRing].pan
    local pan = startPan

	local panConstant = 40 -- make this number bigger if you have problems with loops running into themselves
    local panRate = panConstant / halfSize

    local panRejoinSpan = math.max(circumference*2, 200)
    local panRejoinNode = math.min(#theTrack, endRing + panRejoinSpan)

    if theTrack[panRejoinNode].pan > startPan then
    	panRate = -panRate -- the loop should bend towards the future track segments naturally
    end

    local midRing = startRing + halfSize + math.ceil(halfSize/10)

    for i = startRing+1, endRing do
        theTrack[i].tilt = startTilt + tiltDeltaOverEntireLoop * ((i - startRing) / span)

        if i==midRing then panRate = -panRate end

        pan = pan + panRate -- pan just a little while looping to make sure it doesn't run into itself
        theTrack[i].pan = pan
    end

    local panDeltaCascade = theTrack[endRing].pan - endOriginalPan
    local tiltDeltaCascade = theTrack[endRing].tilt - endOriginalTilt;
    for i = endRing + 1, #theTrack do
        theTrack[i].tilt = theTrack[i].tilt + tiltDeltaCascade
        theTrack[i].pan = theTrack[i].pan + panDeltaCascade
        theTrack[i].funkyrot = true
    end

    return theTrack
end

function InsertCorkscrew(theTrack, startNode, endNode)
	startNode = math.floor(startNode)
	endNode = math.floor(endNode)

	if endNode < #theTrack then
		local cumulativeRoll = theTrack[startNode].roll
		local rollIncrement = 360 / (endNode-startNode)
		--print("endNode:"..endNode)
		local endOriginalRoll = theTrack[endNode].roll

	    for i = startNode, endNode do
	        theTrack[i].roll = cumulativeRoll
	    	cumulativeRoll = cumulativeRoll + rollIncrement
	    	theTrack[i].funkyrot = true
	    end

	    local rollDeltaCascade = theTrack[endNode].roll - endOriginalRoll

	    for i = endNode + 1, #theTrack do
	        theTrack[i].roll = theTrack[i].roll + rollDeltaCascade
	    end
	end

    return theTrack
end

function OnRequestTrackReshaping(theTrack) -- put a loop at each powerpellet to make them easier to see coming
	--local track2 = theTrack
	--print("onrequesttrackreshaping. num powernodes "..#powernodes)

	for i=1,#powernodes do
		local size = 100 + 100 * math.max(1,(theTrack[powernodes[i]].jumpairtime / 10))
		theTrack = InsertLoopyLoop(theTrack, powernodes[i], size)
		if i==1 then--double twist on the strongest loop
			local quickscrewsize = 65
			theTrack = InsertCorkscrew(theTrack, powernodes[i], powernodes[i]+quickscrewsize)
			theTrack = InsertCorkscrew(theTrack, powernodes[i]+quickscrewsize, powernodes[i]+quickscrewsize+size*.75)
		elseif i==#powernodes then
			--no twist on the weakest loop
		else
			theTrack = InsertCorkscrew(theTrack, powernodes[i], powernodes[i]+size*.75)
		end
	end

	track = theTrack
	return track
end

function OnRequestLoadObjects() --load graphic objects here. May be overridden by the skin
	SetBlocks{
		powerups={
			ghost={mesh = "DoubleLozengeXL.obj",
			shader = "RimLight",
			texture = "DoubleLozengeXL.png"},

			powerpellet={mesh = "powerpellet.obj",
			shader = "RimLight",
			texture = "powerpellet.png",
			shadercolors = {_Color="highwayinverted"}}
		}
	}
end

function OnSkinLoaded()-- called after OnTrafficCreated. The skin script has loaded content.
	CreateClone{name="player", prefabName="Vehicle", attachToTrackWithNodeOffset=-1, transform={pos={0,0,1.5}}}
	HideBuiltinPlayerObjects() -- hide the game-controlled vehicle since we're using script-controlled vehicles instead. Also hides the game-controlled surfer
end

score = 0 --the global score (in multiplayer, shared by all players co-operatively)
oneTimeMatchMultiplier = 1

iCurrentRing = 0 --Update function keeps this current
blocksToHide = {}
stealthy = true

function EatPowerPellet(block, isTheBigOne)

end

function EatGhost()
	local points = 500 + (5000 * GetPercentPuzzleFilled(false)) -- passing false tells it to count matched cells
	--score = score + points -- add the shared points earned from this collection batch
	--SetGlobalScore{score=score,showdelta=true}
end

function IsInShoulderLanes(strafe)
	if strafe~=nil and ((strafe > lanespace * 1.5) or (strafe < lanespace * -1.5)) then
		return true
	else
		return false
	end
end

hitGrey = false
spikesHit = 0
blocksEncountered = 0
function Collide(strafe, tracklocation)
	--local playerLane = 0;
	--if strafe>half_lanespace then playerLane = 1
	--elseif strafe<-half_lanespace then playerLane=-1 end
	local playerLane = 0
	--if shoulderlanes and ((strafe > lanespace * 1.5) or (strafe < lanespace * -1.5)) then
	if shoulderlanes and IsInShoulderLanes(strafe) then
		playerLane = 9999
	else
		if strafe>half_lanespace then
			playerLane = 1
		elseif strafe<-half_lanespace then
			playerLane=-1
		end
	end

	local collisionTolerenceAhead = .1
	local collisionToleranceBehind_colors = 2.1
	local collisionToleranceBehind_greys = .5 -- greys don't get a generous collision window the way colors and powerups do

	local maxRing = iCurrentRing + 22
	local foundFirst = false
	for i=player.prevFirstBlockCollisionTested,#blockNodes do
		if not blocks[i].irrelevant then
			if blockNodes[i] <= maxRing then
				if not foundFirst then
					player.prevFirstBlockCollisionTested = i
					foundFirst = true
				end

				--if blockNodes[i] <= math.floor(iCurrentRing) then

				local allowCollision = false

				local collisionToleranceBehind = (blocks[i].type == 5) and collisionToleranceBehind_greys or collisionToleranceBehind_colors

				if blockNodes[i] < (tracklocation - collisionToleranceBehind) then
					if blocks[i].collisiontestcount < 1 then
						allowCollision = true -- make sure each block is allowed at least one collision test, no matter how far behind the impact node it is now
					end
					blocks[i].irrelevant = true
				end

				local isAheadOfMe = false
				if (blockNodes[i] > (tracklocation + collisionTolerenceAhead)) then
					isAheadOfMe = true
				end

				if (blockNodes[i] <= (tracklocation + collisionTolerenceAhead)) and (blockNodes[i] >= (tracklocation - collisionToleranceBehind)) then
					allowCollision = true
				end

				if allowCollision then
					blocks[i].collisiontestcount = blocks[i].collisiontestcount + 1
					if not blocks[i].hidden then
						if (blocks[i].lane == playerLane) then
							blocksEncountered = math.max(blocksEncountered,i) -- a hit block has obviously been encountered
							blocksToHide[#blocksToHide+1] = i
							blocks[i].hidden = true
							local blockOffset = blockOffsets[i]
							local isPowerup = false
							blocksCollected = blocksCollected + 1

							if blocks[i].type == 5 then
								hitGrey = true
								spikesHit = spikesHit + 1
								if stealthy then
									stealthy = false
									--PlaySound{name="landcrash"} -- play crash sound when they lose stealth
									--SetScoreboardNote{text="stealth lost", secondsvisible=1.5}
								--	SetScoreboardNote{text=" "}
								end
							elseif blocks[i].type == 100 then
								EatGhost()
								isPowerup = true
							elseif blocks[i].type == 101 then
								isPowerup = true
								local isTheBigOne = blocks[i].powerRating == 1
								if isTheBigOne then --if this is the biggest jump
									if longestJump > 6 then -- if this jump was over 6 seconds (to avoid crowd roaring on calm songs)
										PlayBuiltInSound{soundType="crowdroar"}
									end
								end
								EatPowerPellet(blocks[i], isTheBigOne)
							end

							if not isPowerup then
							--	SetPuzzle{newblocks={{type=blocks[i].type, collision_strafe=blockOffset[1], puzzle_col=blocks[i].lane+1, add_top=true}}}
							else
							--	SetPuzzle{timing={matchtimer=0}} -- reset the match timer so matches won't collect as long as ghosts keep getting eaten
							end
							SendCommand{command="HoverUp"} -- causes the hovering vehicle to bounce up a bit
						end
					end
					--blocks[i].tested = true
				else
					if not isAheadOfMe then
						blocksEncountered = math.max(blocksEncountered,i) -- no longer possible to hit. This block has been encountered
					end
				end

			else
				break --stop the loop once we get to a block way past the player
			end
			--end
		end
	end
	
	--if #blocksToHide > 0 then UpdateBatchRenderer{uniqueName="BlockBatchRenderer", hideLocations=blocksToHide} end
end

--function OnPuzzleCollecting()
--	local puzzle = GetPuzzle()
--	local matchSize = puzzle["matchedcellscount"]
--
--	if matchSize > 0 then
--		SetPuzzle{timing={collectnow_usingmultiplier=1, collectioncanautoplaysounds=false}}
--		PlaySound{name="matchsmall"}
--	end
--end

function GetPercentPuzzleFilled(countMatchedCellsAsEmpty)
	return 0
end

function GetNextCollisionStrafe() -- figure out which lane the minion should be in
	for i=player.prevFirstBlockCollisionTested,#blockNodes do
		if not blocks[i].tested then
			return blocks[i].lane * lanespace
		end
	end

	return 0
end


function comma_value(amount)
  local formatted = amount
  while true do  
    formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
    if (k==0) then
      break
    end
  end
  return formatted
end

function round(val, decimal)
  if (decimal) then
    return math.floor( (val * 10^decimal) + 0.5) / (10^decimal)
  else
    return math.floor(val+0.5)
  end
end

function format_num(amount, decimal, prefix, neg_prefix)
  local str_amount,  formatted, famount, remain

  decimal = decimal or 2  -- default 2 decimal places
  neg_prefix = neg_prefix or "-" -- default negative sign

  famount = math.abs(round(amount,decimal))
  famount = math.floor(famount)

  remain = round(math.abs(amount) - famount, decimal)

        -- comma to separate the thousands
  formatted = comma_value(famount)

        -- attach the decimal portion
  if (decimal > 0) then
    remain = string.sub(tostring(remain),3)
    formatted = formatted .. "." .. remain ..
                string.rep("0", decimal - string.len(remain))
  end

        -- attach prefix string e.g '$' 
  formatted = (prefix or "") .. formatted 

        -- if value is negative then format accordingly
  if (amount<0) then
    if (neg_prefix=="()") then
      formatted = "("..formatted ..")"
    else
      formatted = neg_prefix .. formatted 
    end
  end

  return formatted
end


function UpdateScoreDisplay()
	blocksMissed = blocksEncountered - blocksCollected
	if blocksMissed <= 0 then
		SetScoreboardNote{text="100%"}
	else
		local percent = 100 * ((blockCount - blocksMissed) / blockCount)
		SetScoreboardNote{text=format_num(percent,1).."%"}
	end
end

prevHitAllLanes = true
prevLeftClick = false
secondsSinceInput = 0
autoPilot = true
autoPilotStrafe = 0

gPlayerStrafe = 0
prevInputStrafe =  0
scoreboardNoteTicker = 0
function Update(dt, tracklocation, playerstrafe, input) --called every frame
	--iCurrentRing = math.floor(GetCurrentTrackLocation())
	--local input = GetInput()

	local playersInput = input["players"]
	local player1Input = playersInput[1]
	local keyHorizontal = player1Input["Horizontal"]

	if autoPilot then
		--move the helper to line it up for the next block hit
		local desiredHelperStrafe = GetNextCollisionStrafe()
		autoPilotStrafe = autoPilotStrafe + dt * 11 * (desiredHelperStrafe - autoPilotStrafe)
		gPlayerStrafe = autoPilotStrafe
	else
		gPlayerStrafe = playerstrafe
	end

	iCurrentRing = math.floor(tracklocation)

	SendCommand{command="SetTransform", name="player", param={pos={gPlayerStrafe,0,1.5}}}
	SetPlayerStrafe(gPlayerStrafe) -- allows the camera to follow behind the vehicle when strafe is controlled by the mod (autopilot)

	hitGrey = false

	blocksToHide = {}
	Collide(gPlayerStrafe, tracklocation)

	scoreboardNoteTicker = scoreboardNoteTicker+dt
	if scoreboardNoteTicker > .2 then
		UpdateScoreDisplay()
		scoreboardNoteTicker = 0
	end

	if #blocksToHide > 0 then
		local pitch = 1 + 2 * GetPercentPuzzleFilled(false)
		PlaySound{name=fif(hitGrey,"hitgreypro", "hit"),pitch=pitch} -- PlaySound{name="hit",pitch=pitch,volume=1,loopseconds=0}
		HideTraffic(blocksToHide)
		local hiddenBlockID = blocksToHide[1]
		local blockType = blocks[hiddenBlockID].type
		FlashAirDebris{colorID=fif(blockType>100, 5, blockType), duration = fif(blockType>100, 1.2, .15), sizescaler = fif(blockType>100, 25.0, 5.0)}
	end
end

function OnRequestFinalScoring()
	local stealthBonus = 0
	if stealthy then stealthBonus = math.floor(score * .25) end

	local percent = 100 * ((blockCount - blocksMissed) / blockCount)
	score = math.floor(percent * 1000)
	if percent==100 then
		score = score + 100
	end
	local randomBonus = math.random()*100
	randomBonus = math.floor(randomBonus)

	return {
		rawscore = score,
		bonuses = {
			--"Stealth Bonus:"..stealthBonus,
			"Random Bonus:"..format_num(randomBonus,0)
		},
		finalscore = score + randomBonus --  + stealthBonus
	}
end