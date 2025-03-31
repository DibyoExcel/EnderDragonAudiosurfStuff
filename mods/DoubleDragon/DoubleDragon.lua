--TODO: port over Collide() and below. uncluding updateplayer functions


--puzzle.lua
lmb = "none"
rmb = "none"
lmbInterval = 0 -- by default, use left mouse button power as often as you want
rmbInterval = 0 -- by default, use right mouse button power as often as you want
passive = nil
passiveInterval = 0
Qsize = 0
triplicateblocks = false
puzzlecolcount = 3
puzzlerowcount = 10
defaultPointsPerWhite = 1500
pointscaler = 1.0
shoulderlanes = true
shoulderTriggersLmbPowerContinuously = false
shoulderTriggerRequiredStartTime = 0 -- time in shoulder before continuous auto-firing can begin
multiColorMatchBonusScalers = {0,.20,.25,.30,.35,.40,.45,.50,.55} -- accomodates more colors than are currently in this mod
cleanFinishBonusScaler = .15
matchClearsGridBonusScaler = 0
seeingRedThreshold = 0.90
seeingRedBonusScaler = 0.05
butterNinjaThreshold = 0.90
butterNinjaBonusScaler = 0.075

--character settings--

--DV--
puzzlecolcount = 4

--pusher--
--lmb = "pushleft"
--rmb = "pushright"
--puzzlerowcount = 8

--eraser--
--lmb = "erase"
--rmb = "undo"

--vegas--
--lmb = "shuffle"
--lmbInterval = 2 -- must wait this long between uses of the power
--rmb = "dQ"
--Qsize = 1
--passive = "generatepowerup"
--passiveInterval = {11,25} --generate a new powerup this often (can be a range for some variability)
--canQpowerups = true
--pointscaler = .75
--shoulderlanes = true
--shoulderTriggersLmbPowerContinuously = true
--shoulderTriggerRequiredStartTime = 0.5

--pointman--
--lmb = "Q"
--rmb = "dQ"
--Qsize = 3
--canQpowerups = true
--canQpowerups_evenMultipliers = false -- if this is true, canQpowerups must also be set true
--puzzlerowcount = 7

--experimental Filterer character
--triplicateblocks = true

--other
greytype = 11
randomizeblocktypes = false

canUndo = lmb=="undo" or rmb=="undo"
canPush = lmb=="pushleft" or rmb=="pushright"
canErase = lmb=="erase" or rmb=="erase"
canShuffle = lmb=="shuffle" or rmb=="shuffle"
canQ = lmb=="Q" or rmb=="Q"

minMatchSizes = minMatchSizes or {}
for i=1,99 do
	minMatchSizes[i] = 3
end
for i=1,33 do
	minMatchSizes[#minMatchSizes+1] = 2 + (puzzlecolcount*puzzlerowcount) -- puzzle blocks created at powerup ids (whiteblocks) will never match (required size is too large)
end

GameplaySettings{
	maxstrafe = fif(shoulderlanes, 6, 3),
	usepuzzlegrid = true,
	puzzlerows = puzzlerowcount,
	puzzlecols = puzzlecolcount,
    greypercent=0.09, -- greys are turned to whites in this mode, so this is percentage of blocks that are white (collect when hit bottom row)
    railedblockscanbegrey = true,

    rightsticksteering = fif(shoulderlanes,true,  fif(canPush, false, true)),--pusher mode can use the right stick for push direction, so don't use it for steering

    preventautomaticoverfillclear = true,

    blocktype_grey = greytype,
    colorcount=1,
    blocktype_highway = 6,
    blocktype_highwayinverted = 7,
    --minmatchsizes = {3,5}, -- overrides minmatchsize when used
    minmatchsizes = minMatchSizes,

    usetraffic = true,
    automatic_traffic_collisions = false, -- the game shouldn't check for block collisions since we'll be doing that ourselves in this script
    jumpmode="none",
    matchcollectionseconds=1.5,
    --greyaction="eraseone", -- "eraseall"  -- "eraseblock"
    greyaction="permanent",
    trafficcompression=0.69,

	--track generation settings
--	gravity=-.45, -- even without jumping the gravity setting is (a little bit) relevant. It's used in generating the track to sculpt it steep enough to allow jumps
--    playerminspeed = 0.1,--so the player is always moving somewhat
--    playermaxspeed = 3.1,--3.1
--    minimumbestjumptime = 2.5,--massage the track until a jump of at least this duration is possible
--    uphilltiltscaler = 1.5,--set to 1 for normal track. higher for steeper
--    downhilltiltscaler = 1.5,--set to 1 for normal track. higher for steeper
--    uphilltiltsmoother = 0.02,
--    downhilltiltsmoother = 0.04,
--    useadvancedsteepalgorithm = true,--set false for a less extreme track
--    alldownhill = false,
    puzzleblockfallinterval = .1,
    blockflight_secondstopuzzle = .25,

	--track generation settings
	gravity=-.45,
    playerminspeed = 0.1,--so the player is always moving somewhat
    playermaxspeed = 2.9,--2.5
    minimumbestjumptime = 2.5,--massage the track until a jump of at least this duration is possible
    uphilltiltscaler = 0.8,--set to 1 for normal track. higher for steeper
    downhilltiltscaler = 1.55,--set to 1 for normal track. higher for steeper
    uphilltiltsmoother = 0.03,
    downhilltiltsmoother = 0.06,
    useadvancedsteepalgorithm = false,--set false for a less extreme track
    alldownhill = false
	--end track generation settings
}

--SetSkinProperties{
--	lanedividers={-1.5,1.5},
--	shoulderlines={-4.5,4.5},
--	trackwidth = fif(shoulderlanes, 8, 5),
--	prefersteep = true
--}

SetSkinProperties{
	lanedividers={-3,0,3},
	shoulderlines={-6,6},
	trackwidth = fif(shoulderlanes, 11.5, 8.5),
	prefersteep = true
}

--player={
--	score=0,
--	prevInput={},
--	iPrevRing=0,
--	hasFinishedScoringPrevRing=false,
--	uniqueName = "Player",
--	num=1,
--	prevFirstBlockCollisionTested = 1,
--	pos = {0,0,0},
--	posCosmetic = {0,0,1.5},
--	controller = "mouse",
--	points = 0 -- used for accumulating points this player earns at each match collection. temp var
--}

if not players then --create the players if they haven't been created yet
	players = {}
	players[1]={
		score=0,
		prevInput={},
		iPrevRing=0,
		hasFinishedScoringPrevRing=false,
		uniqueName = "Right",
		num=1,
		prevFirstBlockCollisionTested = 1,
		pos = {0,0,1.5},
		posCosmetic = {0,0,1.5},
		controller = "mouse",
		highestNodeCollidedAt = 0,
		points = 0 -- used for accumulating points this player earns at each match collection. temp var
	}

	players[2]=deepcopy(players[1])
	players[2].uniqueName = "Left"
	players[2].controller = "key"
	players[2].num = 2;
end

function CompareJumpTimes(a,b) --used to sort the track nodes by jump duration
	return a.jumpairtime > b.jumpairtime
end

function CompareAntiJumpTimes(a,b) --used to sort the track nodes by jump duration
	return a.antiairtime > b.antiairtime
end

powernodes = powernodes or {}
minipbs = minipbs or {}
antinodes = antinodes or {}
lowestaltitude = lowestaltitude or 9999
highestaltitude = highestaltitude or -9999
lowestaltitude_node = lowestaltitude_node or 0
highestaltitude_node = highestaltitude_node or 0
--onTrackCreatedHasBeenCalled = false
longestJump = longestJump or -1

track = track or {}
function OnTrackCreated(theTrack)--track is created before the traffic
	--onTrackCreatedHasBeenCalled = true
	track = theTrack

	local songMinutes = track[#track].seconds / 60

	for i=1,#track do
		track[i].jumpedOver = false -- if this node was jumped over by a higher proiority jump
		--track[i].miniJumpedOver = false
		track[i].origIndex = i
		track[i].antiOver = false
	end

	--find the best jumps path in this song
	local strack = deepcopy(track)
	table.sort(strack, CompareJumpTimes)

	--print("POWERNODE calculations. Best air time "..strack[1].jumpairtime)

	for i=1,#strack do
--		if strack[i].origIndex > 300 then
		if strack[i].jumpairtime >= 2.2 then --only consider jumps of at least this amount of air time
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
					local isMajorPB = (#powernodes < songMinutes)
					--if #powernodes < (songMinutes + 1) then -- allow about one power node per minute of music
					if strack[i].origIndex > 300 then
						if isMajorPB then
							powernodes[#powernodes+1] = {ring=strack[i].origIndex, airtime=strack[i].jumpairtime}
						else
							minipbs[#minipbs+1] = {ring=strack[i].origIndex, airtime=strack[i].jumpairtime}
						end
						--print("added powernode at ring "..strack[i].origIndex)
					end
					jumpEndSeconds = strack[i].seconds + strack[i].jumpairtime + 10
					for j=strack[i].origIndex, #track do
						if track[j].seconds <= jumpEndSeconds then
							track[j].jumpedOver = true --mark this node as jumped over (a better jump took priority) so it is not marked as a powernode
						else
							break
						end
					end
					--end
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

function GetStrafeFromLane(lane)
	local strafe = 0
	if puzzlecolcount%2 == 0 then --if using an even number of lanes
		strafe = lane*lanespace
		if strafe < 0 then strafe = strafe + half_lanespace
		else strafe = strafe - half_lanespace end
	else -- using an odd number of lanes
		strafe = lane * lanespace
	end

	return strafe
end

function GetRandomLaneAndStrafe()
	local lane = 0
	local strafe = 0

	if puzzlecolcount%2 == 0 then --if using an even number of lanes
		local maxlane = puzzlecolcount / 2
		while lane == 0 do -- with an even lane count there is no center lane, so loop until we get a nonzero lane
			lane = math.random(-maxlane,maxlane)
		end

		--strafe = lane*lanespace
		--if strafe < 0 then strafe = strafe + half_lanespace
		--else strafe = strafe - half_lanespace end
	else -- using an odd number of lanes
		local maxlane = math.floor(puzzlecolcount / 2.0)
		lane = math.random(-2,2)
		--strafe = lane * lanespace
	end

	strafe = GetStrafeFromLane(lane)

	return lane,strafe -- return multiple values
end

blocks = blocks or {}
blockNodes = blockNodes or {}
blockOffsets = blockOffsets or {}
--blockColors = blockColors or {}
traffic = traffic or {}
whiteblocktype = 111
blockColorTotals = blockColorTotals or {}

function OnTrafficCreated(theTraffic)
	half_lanespace = lanespace / 2

	traffic = theTraffic


--	local colorCounts = {0,0,0,0}
--	colorCounts[0] = 0 -- color types start at zero
--	for i=1,#traffic do
--		local tp = traffic[i].type
--		if tp > 4 or tp < 0 then
--			print("tb:"..tp)
--		else
--			colorCounts[tp] = colorCounts[tp] + 1
--		end
--	end
--	print("percentPurple:"..(colorCounts[0] / #traffic))
--	print("percentBlue:"..(colorCounts[1] / #traffic))
--	print("percentYellow:"..(colorCounts[2] / #traffic))
--	print("percentRed:"..(colorCounts[3] / #traffic))


	local minimapMarkers = {}

	for j=1,#powernodes do --insert powernodes into the traffic
		local pname = "x3"
		local pid = 123
		if j==1 then
			pname = "x4"
			pid = 124
		elseif j==#powernodes then
			pname = "x2"
			pid = 122
		end
		local prev = 2
		for i=prev, #traffic do
			if traffic[i].chainend >= powernodes[j].ring then
				if traffic[i].chainstart <= powernodes[j].ring then
					traffic[i].powerupname = pname
					traffic[i].type = pid -- replace the block already at this node with a power pellet.
					traffic[i].powerRating = j
				else
					table.insert(traffic, i, {powerupname=pname, type=pid, impactnode=powernodes[j].ring, chainstart=powernodes[j].ring, chainend=powernodes[j].ring, lane=0, strafe=0, strength=10, powerRating=j})
				end
				prev = i

				table.insert(minimapMarkers, {tracknode=powernodes[j].ring, startheight=0, endheight=fif(j==1, 33, 11), color=fif(j==1, {233,233,233}, nil) })

				break
			end
		end
	end

	--fix most troll PBs by extending the front of the PBs chainspan
    for i = 2, #traffic do
    	if traffic[i].type > 122 then
    		local prevBlock = traffic[i-1]
    		local prevBlockChainEndSeconds = track[prevBlock.chainend].seconds
    		if (track[traffic[i].chainstart].seconds - track[prevBlock.chainend].seconds) > 1.3 then
    			for j=traffic[i].chainstart, prevBlock.chainend, -1 do
    				if track[j].seconds - prevBlockChainEndSeconds < 1.3 then
    					if (traffic[i].chainstart - j) < 100 then
    						traffic[i].chainstart = j
    					end
    					break
    				end
    			end
    		end
    	end
    end

    local miniPBsPerColor = math.max(1, math.floor((#minipbs) / 4.0))
	for j=1,#minipbs do --insert mini powerblocks into the traffic
		local pname = "paint0"
		local pid = 106
		local colorid = 0
		if j<=miniPBsPerColor then
			pname = "paint3"
			pid = 109
			colorid = 3
		elseif j<=(2*miniPBsPerColor) then
			pname = "paint2"
			pid = 108
			colorid = 2
		elseif j<=(3*miniPBsPerColor) then
			pname = "paint1"
			pid = 107
			colorid = 1
		end
		local prev = 2
		local chainstart = minipbs[j].ring
		local chainend = minipbs[j].ring
		local impactNode = minipbs[j].ring
		for i=prev, #traffic do
			if traffic[i].chainend >= minipbs[j].ring then
				local paintlane = 0 -- fif(math.random()>0.5, 1, -1)
				local paintstrafe = 0 -- paintlane * lanespace
				paintlane, paintstrafe = GetRandomLaneAndStrafe()
				if traffic[i].chainstart <= minipbs[j].ring then
					traffic[i].powerupname = pname
					traffic[i].type = pid -- replace the block already at this node with a power pellet. 101 as a type doesn't mean anything to the game, but the script uses it
					traffic[i].powerRating = j
					chainstart = traffic[i].chainstart
					chainend = traffic[i].chainend
					traffic[i].lane = paintlane
					traffic[i].strafe = paintstrafe
					impactNode = traffic[i].impactnode
				else
					table.insert(traffic, i, {powerupname=pname, type=pid, impactnode=impactNode, chainstart=chainstart, chainend=chainend, lane=paintlane, strafe=paintstrafe, strength=10, powerRating=j})
				end

				--insert a matching storm so the player can choose between paint or storm
				--OK to insert while looping on this table because the loop is about to break
				--pname = "storm"..colorid
				--local stormlane = -paintlane
				--local stormstrafe = stormlane * lanespace
				--table.insert(traffic, i, {powerupname=pname, type=110, impactnode=impactNode, chainstart=chainstart, chainend=chainend, lane=stormlane, strafe=stormstrafe, strength=10, powerRating=j})

				prev = i

				table.insert(minimapMarkers, {tracknode=minipbs[j].ring, startheight=0, endheight=-15, color=colorid })

				break
			end
		end
	end

	AddMinimapMarkers(minimapMarkers)

	--math.randomseed(GetMillisecondsSinceStartup()) --randomize traffic so it is different every time even for the same song

	local blockIndex = 1

    for i = 1, #traffic do
    	local lane = 0 -- math.random(-1,1)
    	local strafe = 0
    	lane,strafe = GetRandomLaneAndStrafe()
    	--if traffic[i].type >= 100 then
    	--	lane = 0 -- powerups default to the center lane
    	--end
    	traffic[i].lane = lane
    	traffic[i].strafe = strafe

    	if randomizeblocktypes then
	    	if(traffic[i].type < 100) then --keep the powerups where they were already calculated
	    		if(math.random()<=0.75) then --randomize block colors instead of leaving them representative of song strength
	    			traffic[i].type = 6 --color
	    		else
	    			traffic[i].type = 5 --grey
	    		end
	    	end
    	end

    	--make sure powerups don't overlap with any chainspans
    	if traffic[i].type >=100 then
    		local powerupImpactNode = traffic[i].impactnode
    		local powerupLane = traffic[i].lane
    		for k=1,#traffic do
    			if (traffic[k].chainstart <= powerupImpactNode) and (traffic[k].chainend >= powerupImpactNode) and (traffic[k].type < 100) then
    				while traffic[k].lane == powerupLane do
    					--traffic[k].lane = math.random(-1,1)
    					traffic[k].lane, traffic[k].strafe = GetRandomLaneAndStrafe()
    				end
    			end
    		end
    	end

    	--local strafe = traffic[i].lane * lanespace
    	--traffic[i].strafe = strafe
    	local offset = {strafe,0,0}

    	local span = traffic[i].chainend - traffic[i].chainstart
    	local caterpillarstart = traffic[i].impactnode;
    	local caterpillarend = traffic[i].impactnode;
    	local iscaterp = false

    	for j=caterpillarstart, caterpillarend do --build out grey caterpillars as block chains
			local block = deepcopy(traffic[i])
			if iscaterp then
				block.impactnode = j
				block.chainstart = block.impactnode
				block.chainend = block.impactnode
			end

			if (not iscaterp) or (j==caterpillarstart) or (j==caterpillarend) or (j%3==0) then --sparse caterpillars to keep the block count down
				block.lane = traffic[i].lane
				block.hidden = false
				block.irrelevant = false
				block.collisiontestcount = 0
				block.seconds = track[block.impactnode].seconds


				block.trackedscales = {
					{nodestoimpact=-1, scale={.75,.75,.75}},
					{nodestoimpact=1, scale={1.75,1.75,1.75}},
					{nodestoimpact=5, scale={1,1,1}}
				}


				block.index = blockIndex
				blocks[#blocks+1]=block
				blockNodes[#blockNodes+1] = block.impactnode
				blockOffsets[#blockOffsets+1] = offset

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
    	if ((block.impactnode-prevnode) < minnodespace) or ((block.seconds-prevseconds) < minsecspace) then
    		--this block is very close with the one behind it
    		if block.type ~= prevtype then
    			--they're not the same type, so make sure they're not in the same lane
    			while block.lane == prevlane do
    				--block.lane = math.random(-1,1)
    				block.lane, block.strafe = GetRandomLaneAndStrafe()
    			end
    		else
    			--they're the same type, so make sure they're in the same lane
    			block.lane = prevlane
    			block.strafe = GetStrafeFromLane(prevlane)
    		end
    	end
    	--local strafe = block.lane * lanespace
    	--block.strafe = strafe
    	local offset = {block.strafe,0,0}

    	blocks[i] = block
    	blockOffsets[i] = offset

    	prevtype = block.type
    	prevlane = block.lane
    	prevseconds = block.seconds
    	prevnode = block.impactnode
    end

    --just making sure....
    for i=1, #blocks do
    	blocks[i].strafe = GetStrafeFromLane(blocks[i].lane)
    end

    local tblocks = {}
    if triplicateblocks then
    	blockOffsets = {}
    	blockNodes = {}
    	for i=1, #blocks do
    		local taboolane = GetRandomLaneAndStrafe()
    		for blane=-2,2 do
    			if blane ~= taboolane and blane~=0 then
	    			local tblock = deepcopy(blocks[i])
	    			tblock.lane = blane
	    			tblock.strafe = (tblock.lane * lanespace) + fif(tblock.strafe < 0, half_lanespace, -half_lanespace)
	    			tblocks[#tblocks+1] = tblock
	    			blockOffsets[#blockOffsets+1] = {tblock.strafe,0,0}
	    			blockNodes[#blockNodes+1] = tblock.impactnode
    			end
    		end
    	end

    	blocks = tblocks
    else
    	tblocks = blocks
    end

    for i,v in ipairs(tblocks) do
    	if v.type == greytype then
    		v.type = whiteblocktype
    		v.powerupname = "whiteblock"
    	end
    end

    for i = 1, #blocks do
		local btype = blocks[i].type
		if blockColorTotals[btype] == nil then
			blockColorTotals[btype] = 1
		else
			blockColorTotals[btype] = blockColorTotals[btype] + 1
		end
	end

    return tblocks--traffic -- when you return a traffic table from this function the game will read and apply any changes you made
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
	for i=1,#powernodes do
--		if i < #powernodes then --leave the weakest jump as a corkscrew. The rest are loops
			local size = 100 + 100 * math.max(1,(theTrack[powernodes[i].ring].jumpairtime / 10))
			theTrack = InsertLoopyLoop(theTrack, powernodes[i].ring, size)
			if i==1 then--double twist on the strongest loop
				local quickscrewsize = 65
				theTrack = InsertCorkscrew(theTrack, powernodes[i].ring, powernodes[i].ring+quickscrewsize)
				theTrack = InsertCorkscrew(theTrack, powernodes[i].ring+quickscrewsize, powernodes[i].ring+quickscrewsize+size*.75)
			elseif i==#powernodes then
				--no twist on the weakest loop
			else
				theTrack = InsertCorkscrew(theTrack, powernodes[i].ring, powernodes[i].ring+size*.75)
			end
	end

	track = theTrack
	return track
end

powerups = powerups or {}
function OnRequestLoadObjects() --load graphic objects here. May be overridden by the skin
	--[[
			ghost={mesh = "DoubleLozengeXL.obj",
				shader = "RimLight",
				texture = "DoubleLozengeXL.png"},

			powerpellet={mesh = "powerpellet.obj", -- powercube
				shader = "RimLight",
				texture = "powerpellet.png",
				shadercolors = {_Color="highwayinverted"}},

			minipb={mesh = "powerpellet.obj", -- minipb
				shader = "RimLight",
				texture = "powerpellet.png",
				shadercolors = {_Color="highwayinverted"}},
	--]]

	powerups = {
			whiteblock={
				mesh = "slantblock.obj",
				shader = "UnlitTintedTex",--fif(ispuzzle, "Diffuse", "VertexColorUnlitTintedAddDepthWrite"),
				texture = "slantblock.png"},
			paint0={
				mesh = "paint.obj",
				shader = "UnlitTintedTex",--fif(ispuzzle, "Diffuse", "VertexColorUnlitTintedAddDepthWrite"),
				blockcolorid=0,
				cangenerate = true,
				texture = "paint.png"},
			paint1={
				mesh = "paint.obj",
				shader = "UnlitTintedTex",--fif(ispuzzle, "Diffuse", "VertexColorUnlitTintedAddDepthWrite"),
				blockcolorid=1,
				cangenerate = true,
				texture = "paint.png"},
			paint2={
				mesh = "paint.obj",
				shader = "UnlitTintedTex",--fif(ispuzzle, "Diffuse", "VertexColorUnlitTintedAddDepthWrite"),
				blockcolorid=2,
				cangenerate = true,
				texture = "paint.png"},
			paint3={
				mesh = "paint.obj",
				shader = "UnlitTintedTex",--fif(ispuzzle, "Diffuse", "VertexColorUnlitTintedAddDepthWrite"),
				blockcolorid=3,
				cangenerate = true,
				texture = "paint.png"},
			paint111={ --whitepaint
				mesh = "paint.obj",
				shader = "UnlitTintedTex",--fif(ispuzzle, "Diffuse", "VertexColorUnlitTintedAddDepthWrite"),
				blockcolorid=111,
				cangenerate = true,
				texture = "paint.png"},

			storm0={
				mesh = "storm.obj",
				shader = "UnlitTintedTex",
				blockcolorid = 0,
				cangenerate = true,
				texture="White.png"},
			storm1={
				mesh = "storm.obj",
				shader = "UnlitTintedTex",
				blockcolorid = 1,
				cangenerate = true,
				texture="White.png"},
			storm2={
				mesh = "storm.obj",
				shader = "UnlitTintedTex",
				blockcolorid = 2,
				cangenerate = true,
				texture="White.png"},
			storm3={
				mesh = "storm.obj",
				shader = "UnlitTintedTex",
				blockcolorid = 3,
				cangenerate = true,
				texture="White.png"},
			storm111={ -- whitestorm
				mesh = "storm.obj",
				shader = "UnlitTintedTex",
				cangenerate = true,
				texture="White.png"},

			x2={
				mesh = "x2.obj",
				shader = "UnlitTintedTex",--fif(ispuzzle, "Diffuse", "VertexColorUnlitTintedAddDepthWrite"),
				texture = "White.png"},
			x3={
				mesh = "x3.obj",
				shader = "UnlitTintedTex",--fif(ispuzzle, "Diffuse", "VertexColorUnlitTintedAddDepthWrite"),
				texture = "White.png"},
			x4={
				mesh = "x4.obj",
				shader = "UnlitTintedTex",--fif(ispuzzle, "Diffuse", "VertexColorUnlitTintedAddDepthWrite"),
				texture = "White.png"},
			x5={
				mesh = "x5.obj",
				shader = "UnlitTintedTex",--fif(ispuzzle, "Diffuse", "VertexColorUnlitTintedAddDepthWrite"),
				texture = "White.png"},

			sort={
				mesh = "sort.obj",
				shader = "UnlitTintedTex",
				cangenerate = true,
				texture = "White.png"},

			trispike={
				mesh = "trispike.obj",
				shader = "RimLight",
				texture = "trispike.png"}
		}

	SetBlocks{
		powerups=powerups
	}

	CreateObject{
		name="PushLeft",
		active= true,
		visible = false,
		gameobject={
			transform={pos={0,0,0}},
			mesh="PushLeft.obj",
			shader="VertexColorUnlitTinted",
			shadercolors={
				_Color={255,255,255}
			}
		}
	}

	CreateObject{
		name="PushRight",
		active= true,
		visible = false,
		gameobject={
			transform={pos={0,0,0}},
			mesh="PushRight.obj",
			shader="VertexColorUnlitTinted",
			--texture = "FullLeftArm_1024_wAO.png",
			shadercolors={
				_Color={255,255,255}
			}
		}
	}

	CreateObject{
		name="Eraser",
		active= true,
		visible = false,
		gameobject={
			transform={pos={0,0,0}},
			mesh="Eraser.obj",
			shader="VertexColorUnlitTinted",
			--texture = "FullLeftArm_1024_wAO.png",
			shadercolors={
				_Color={255,255,255}
			}
		}
	}

	CreateObject{
		name="Vegas",
		active= true,
		visible = false,
		gameobject={
			transform={pos={0,0,0}},
			mesh="spade.obj",
			shader="VertexColorUnlitTinted",
			shadercolors={
				_Color={255,255,255}
			}
		}
	}

	CreateObject{
		name="Scoop",
		active= true,
		visible = false,
		gameobject={
			transform={pos={0,0,0}},
			mesh="scoop.obj",
			shader="VertexColorUnlitTinted",
			shadercolors={
				_Color={255,255,255}
			}
		}
	}

	CreateObject{
		name="undomarker",
		active= true,
		visible = false,
		--railoffset = 0.5,
		gameobject={
			transform={pos={0,0,0}},
			mesh="flatbox.obj",
			shader="VertexColorUnlitTinted",
			shadercolors={
				_Color={255,255,255}
			}
		}
	}

	LoadSounds{
		whiteatbottom="whiteatbottom.wav",
		shuffle = "shuffleshort.wav",
		erase = "erase.wav",
		push = "push.wav",
		queue = "erase.wav",
		paint = "paint.wav",
		storm = "storm.wav"
	}
end

puzzleColors = puzzleColors or nil

function OnSkinLoaded()-- called after OnTrafficCreated. The skin script has loaded content.
	if canPush then
		CreateClone{name="PushLeft", prefabName="PushLeft", attachToTrackWithNodeOffset=0, transform={pos={0,0,0}}}
		CreateClone{name="PushRight", prefabName="PushRight", attachToTrackWithNodeOffset=0, transform={pos={0,0,0}}}
	end

	if canErase then
		CreateClone{name="Eraser", prefabName="Eraser", attachToTrackWithNodeOffset=0, transform={pos={0,0,0}}}
	end

	if canShuffle then
		CreateClone{name="Vegas", prefabName="Vegas", transform={pos={0,.52,0}, rotation={13.5,0,0}, scale={.6,.6,.6}}}
		SendCommand{command="SetRenderLayerRecursively", name="Vegas", param={layer=15}}
	end

	if canQ then
		CreateClone{name="Scoop", prefabName="Scoop", transform={pos={0,.467,-.94}, rotation={0,0,0}, scale={.76,.76,.76}}}
		SendCommand{command="SetRenderLayerRecursively", name="Scoop", param={layer=15}}
	end

	for i=1,Qsize do
		local scale = {.18, .18, .18}
		if (Qsize > 1) and i==1 then
			scale = {.29,.29,.29}
		end
		CreateClone{name="Qblock"..i, prefabName="builtin_trafficblock", transform={scale=scale, pos={0,0,0}}}
		SendCommand{command="SetRenderLayerRecursively", name="Qblock"..i, param={layer=15}}
	end

	if canPush then
		SendCommand{command="Hide", name="PushRight"}
		SendCommand{command="Hide", name="PushLeft"}
	end
	if canErase then
		SendCommand{command="Hide", name="Eraser"}
	end

	if canUndo then
		for i=1, puzzlecolcount do  -- i is column index (1-3)
			local strafe = (i-2)*lanespace
			for j=1, puzzlerowcount do -- j is row index (1-7)
				CreateClone{
					name="undomarker"..i..j,
					prefabName = "undomarker",
					attachToTrackWithNodeOffset=0.5,
					transform={pos={strafe,0.16,0}, scale={1.34,0.2,0.08}}
				}
			end
		end
	end

	CreateClone{name=players[1].uniqueName, prefabName="Vehicle", attachToTrackWithNodeOffset=-1, transform={pos=players[1].pos}}
	CreateClone{name=players[2].uniqueName, prefabName="Vehicle", attachToTrackWithNodeOffset=-1, transform={pos=players[2].pos}}

	SetPuzzle{trackoffset=-.25}

	HideBuiltinPlayerObjects() -- hide the game-controlled vehicle since we're using script-controlled vehicles instead. Also hides the game-controlled surfer

	--SetCamera{ -- calling this function (even just once) overrides the camera settings from the skin script
	--	pos={0,6.87,-1.9},
	--	rot={34.85,0,0}
	--}

	SetCamera{ -- calling this function (even just once) overrides the camera settings from the skin script
		nearcam={
			pos={0,4,-3.50475},
			rot={38,0,0},
			strafiness = 0
		},
		farcam={
			pos={0,12.8,-3.50475},
			rot={41,0,0},
			strafiness = 0
		}
	}

	puzzleColors = GetBlockColors()
end



function FullyLowerPuzzleBlocks(puzz) -- NOTE: this function modifies the passed puzzle. It does not sync puzzle state to the game engine
	local ret = true
	local dirty = false
	while ret do
		ret = LowerPuzzleBlocksByOne(puzz)
		if ret then dirty = true end
	end

	return dirty
end

function LowerPuzzleBlocksByOne(puzz) -- NOTE: this function modifies the passed puzzle. It does not sync puzzle state to the game engine
	local currentPuzzle = puzz["cells"]
	local dirty = false
	for i=1,#currentPuzzle do -- columns (1-3)
		local ct = currentPuzzle[i]
		for j=1,(#ct-1) do
			local cell = ct[j]
			local cellAbove = ct[j+1]
			if cell["type"] < 0 then --this cell is empty, pull down the one above it
				if cellAbove["type"] >= 0 then
					cell["type"] = cellAbove["type"]
					cellAbove["type"] = -1
					dirty = true
				end
			end
		end
	end

	if dirty then
		return true
	else
		return false
	end
end

lastframewhitesoundplayed = lastframewhitesoundplayed or 0
function PlayWhiteCollectedSound()
	if lastframewhitesoundplayed < framecount then
		PlaySound{name="whiteatbottom"}
		lastframewhitesoundplayed = framecount
	end
end

function CollectAllBottomRowWhiteBlocks(puzz, pointsperwhite) -- NOTE: this function modifies the puzzle as a side-effect. It does not sync puzzle state to the game engine
	local currentPuzzle = puzz["cells"]
	local dirty = false
	local flyups = {}
	local numCollected = 0
	if pointsperwhite==nil then pointsperwhite = defaultPointsPerWhite end
	local deltaPoints = 0
	for i=1,#currentPuzzle do  -- i is column index (1-3)
		local ct = currentPuzzle[i]
		local cell = ct[1]
		local ctype = cell["type"]
		if ctype == whiteblocktype then -- a white at the bottom, collect it
			PlayWhiteCollectedSound()
			deltaPoints = deltaPoints + pointsperwhite*pointscaler
			cell["type"] = -1
			dirty = true
			lastTimeWhitesCollected = timeSoFar
			flyups[#flyups+1] = {row=0,col=i-1,type=whiteblocktype}
			numCollected = numCollected + 1
		end
	end

	if deltaPoints > 0 then
		score = score + deltaPoints
		SetGlobalScore{score=score,showdelta=true}
	end


	if dirty then
		puzz["flyups"] = flyups
	end

	return numCollected
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

chainCount = chainCount or 0
function ChangeChainCount(increment)
	local oldChainCount = chainCount

	if increment == 0 then
		chainCount = 0
	else
		chainCount = chainCount+increment
	end

	if oldChainCount ~= chainCount then
		if chainCount <= 1 then
			if oldChainCount >= 1 then
				SetScoreboardNote{text="chain bonus ended", secondsvisible=1.5}
			else
				SetScoreboardNote{text="", secondsvisible=1.5}
			end
		else
			chainMultiplier = GetChainMultiplier_FromChainCount(chainCount)
			SetScoreboardNote{text="x"..format_num(chainMultiplier, 1), color={195,195,195}, secondsvisible=0} -- visible time of 0 means it doesn't expire
		end
	end
end

function GetChainMultiplier_FromChainCount(count)
	if count >= 30 then return 4
	elseif count >= 25 then return 3.7
	elseif count >= 20 then return 3.4
	elseif count >= 15 then return 3.1
	elseif count >= 10 then return 2.8
	elseif count >= 5 then return 2.5
	elseif count >= 4 then return 2.25
	elseif count >= 3 then return 1.9
	elseif count >= 2 then return 1.5
	elseif count >= 1 then return 1
	else return 1 end
end

function ClearPuzzle(numBottomUpRowsToClear)
	numBottomUpRowsToClear = numBottomUpRowsToClear or puzzlerowcount -- default to full puzzle clear if no parameters were passed

	local puzz = GetPuzzle()
	local currentPuzzle = puzz["cells"]
	for i=1,#currentPuzzle do
		local ct = currentPuzzle[i]
		for j=1,numBottomUpRowsToClear do
			local cell = ct[j]
			cell["type"] = -1
		end
	end

	puzz["timing"] = {matchtimer=0}
	SetPuzzle(puzz)
end

runningOverfillCo = false
function OverfillCo()
	runningOverfillCo = true

	PlaySound{name="overfill"}
	waitSeconds(.2)
	ClearPuzzle(3)

	runningOverfillCo = false
end

function OnPuzzleOverfill() --called from the game engine when the puzzle overfills
	ChangeChainCount(0)

	if not runningOverfillCo then
		local co = coroutine.create(OverfillCo)
	    return coroutine.resume(co)
	end
end

function GetHighestPuzzleCellsRow(puzzle) -- NOTE: makes no changes to the passed puzzle
	local highestFilledCellRow = -1
	local cells = puzzle["cells"]
	for colnum=1,#cells do
		local col = cells[colnum]
		for rownum=1,#col do
			local cell = col[rownum]
			if cell.type >=0 then
				highestFilledCellRow = math.max(highestFilledCellRow, rownum)
			end
		end
	end

	return highestFilledCellRow
end

function OnPuzzleBlockAdded() -- Called by the game each time a block is added to the puzzle
	local puzz = GetPuzzle()
	local highestFilledCellRow = GetHighestPuzzleCellsRow(puzz)
	if highestFilledCellRow >= (puzzlerowcount-2) then -- we're getting close to a filled column. make sure an overfill above white blocks can't happen
		local numWhitesCollected = CollectAllBottomRowWhiteBlocks(puzz) -- collect whites. Note that they don't benefit from the chain bonus
		if numWhitesCollected>0 then --puzzle was changed as white blocks were removed
			SetPuzzle(puzz)
		end
	end
end

score = 0 --the global score (in multiplayer, shared by all players co-operatively)
largestMatch = largestMatch or 0
blockColors = nil
function OnPuzzleCollecting(isForceClear)
	local points = 0
	local hasAtLeastOneSharedMatch = false

	local puzzle = GetPuzzle()

	local numWhitesCollected = CollectAllBottomRowWhiteBlocks(puzzle)
	local collectedWhites = false

	if numWhitesCollected > 0 then
		collectedWhites = true
	end

	local hasMatches = false
	local matchSize = puzzle["matchedcellscount"]
	local chainMultiplier = 1
	local matchedCountByColor = {0,0,0,0,0,0,0,0,0,0}
	local rawPointsByColor = {0,0,0,0,0,0,0,0,0,0}
	local unmatchedUnwhiteCells = 0
	local unmatchedCells = 0
	local deltaPlayerPoints = {}
	deltaPlayerPoints[1] = 0
	deltaPlayerPoints[2] = 0
	if matchSize >= 1 then
		chainMultiplier = GetChainMultiplier_FromChainCount(chainCount)
		local cells = puzzle["cells"]
		for colnum=1,#cells do -- 1-3
			local col = cells[colnum]
			for rownum=1,#col do -- 1-7
				local cell = col[rownum]
				local celltype = cell["type"]
				local base1celltype = celltype + 1
				if cell["matched"] then
					matchedCountByColor[base1celltype] = matchedCountByColor[base1celltype] + 1
					--local cellPoints = 5 * ((cell["type"]+6) * cell["matchsize"])
					local cellPoints = 10 * ((cell["type"]+1) * cell["matchsize"])
					rawPointsByColor[base1celltype] = rawPointsByColor[base1celltype] + cellPoints;
					points = points + cellPoints
					local matchCols = cell["matchcols"] -- set true for each column involved in the match this cell is a part of
					--print("matchCols[0]:"..fif(matchCols[0],"true","false")) -- debug info to output_log.txt
					--print("matchCols[1]:"..fif(matchCols[1],"true","false"))
					--print("matchCols[2]:"..fif(matchCols[2],"true","false"))
					--print("matchCols[3]:"..fif(matchCols[3],"true","false"))
					--print("matchCols[4]:"..fif(matchCols[4],"true","false"))
					--print("matchCols[5]:"..fif(matchCols[5],"true","false"))
					if matchCols[1] or matchCols[2] then -- player1 covers these columns
						deltaPlayerPoints[1] = deltaPlayerPoints[1] + cellPoints
					end
					if matchCols[3] or matchCols[4] then
						deltaPlayerPoints[2] = deltaPlayerPoints[2] + cellPoints
					end
					if (matchCols[1] or matchCols[2]) and (matchCols[3] or matchCols[4]) then
						hasAtLeastOneSharedMatch = true
					end
				else
					if celltype >= 0 then -- if cell is not empty
						unmatchedCells = unmatchedCells + 1
						if celltype ~= whiteblocktype then
							unmatchedUnwhiteCells = unmatchedUnwhiteCells + 1
						end
					end
				end
			end
		end

		local numColorsMatched = 0
		for base1celltype=1,#matchedCountByColor do
			if matchedCountByColor[base1celltype] > 0 then
				numColorsMatched = numColorsMatched + 1
			end
		end

		points = (points * (chainMultiplier + additiveMatchMultiplier))  -- + multiColorMatchBonus + clearedGridBonus

		local multiColorMatchBonus = points * multiColorMatchBonusScalers[numColorsMatched] -- multiColorMatchBonusScalers = {0,.20,.25,.30,.35,.40}

		local clearedGridBonus = 0
		if unmatchedCells < 1 then
			clearedGridBonus = points * matchClearsGridBonusScaler
		end

		points = points + multiColorMatchBonus + clearedGridBonus


		local p1_prepoints = (deltaPlayerPoints[1] * (chainMultiplier + additiveMatchMultiplier));
		deltaPlayerPoints[1] = p1_prepoints + p1_prepoints*multiColorMatchBonusScalers[numColorsMatched] + p1_prepoints*clearedGridBonus

		local p2_prepoints = (deltaPlayerPoints[2] * (chainMultiplier + additiveMatchMultiplier));
		deltaPlayerPoints[2] = p2_prepoints + p2_prepoints*multiColorMatchBonusScalers[numColorsMatched] + p2_prepoints*clearedGridBonus
		--deltaPlayerPoints[2] = (deltaPlayerPoints[2] * (chainMultiplier + additiveMatchMultiplier)) + multiColorMatchBonus + clearedGridBonus

		local sharedMatchMultiplier = 1 + fif(hasAtLeastOneSharedMatch, .5, 0)

		local deltaPoints = points * sharedMatchMultiplier * pointscaler
		deltaPlayerPoints[1] = deltaPlayerPoints[1] * sharedMatchMultiplier * pointscaler
		deltaPlayerPoints[2] = deltaPlayerPoints[2] * sharedMatchMultiplier * pointscaler

		players[1].points  = players[1].points + deltaPlayerPoints[1]
		players[2].points  = players[2].points + deltaPlayerPoints[2]

		--if sharedMatchMultiplier > 1 then
			--SetScoreboardNote{text="Shared Match!", color={195,195,195}, secondsvisible=1.5}
		--end


		local totalRawPoints = 0
		for i=1,#rawPointsByColor do
			totalRawPoints = totalRawPoints + rawPointsByColor[i]
		end
		local scoreContributionByColor = {0,0,0,0,0,0,0,0,0,0}
		for i=1,#rawPointsByColor do
			scoreContributionByColor[i] = rawPointsByColor[i] / totalRawPoints
		end

		if blockColors == nil then blockColors = GetBlockColors() end
		--tell the game how many points each color is responsible for adding to the score
		for i=1,#scoreContributionByColor do
			if scoreContributionByColor[i] > 0 then
				local contribution = math.floor(.5 + (deltaPoints * scoreContributionByColor[i]))
				score = score + contribution
				local dc = {1,1,1}
				if i<=#blockColors then
					dc = blockColors[i]
				end
				
				SetGlobalScore{score=score, showdelta=true, deltacolor=dc}
			end
		end



		--score = score + points * pointscaler -- add the shared points earned from this collection batch
		--SetGlobalScore{score=score,showdelta=true}
		puzzle["timing"] = {collectnow_usingmultiplier=chainMultiplier, collectioncanautoplaysounds=true}
		hasMatches = true
		ChangeChainCount(1)
	else
		ChangeChainCount(0)
	end

	largestMatch = math.max(largestMatch, matchSize)

	if hasMatches or collectedWhites then
		puzzle["cells"] = nil -- we don't want to set the puzzle to its pre-match state after the matches are collected
		SetPuzzle(puzzle)
	end
end

iCurrentRing = 0 --Update function keeps this current
blocksToHide = {}
stealthy = true

pushDirection = 0 -- just used for showing correct eraser graphics, even though there's no pushing in this mode

ecells = {} -- current bank of erased cells to undo back to puzzle
additiveMatchMultiplier = additiveMatchMultiplier or 0
function CollectAllMatches(multiplier, whitesmultiplier) --collect all matches, including gravity matches and whites
	local chainMultiplier = GetChainMultiplier_FromChainCount(chainCount)
	if multiplier == nil then multiplier = 1 end
	if whitesmultiplier==nil then whitesmultiplier = multiplier end
	--multiplier = multiplier + chainMultiplier
	additiveMatchMultiplier = multiplier - 1 -- onpuzzlecollecting will use this to get the score correct

	local looping = true
	local blocksCollected = 0
	local whitesCollected = 0
	local puzz = nil
	local iterations = 0
	while looping and (iterations < 100) do
		local dirty = false
		puzz = GetPuzzle()
		local matchSize = puzz["matchedcellscount"]
		if matchSize > 0 then
			local puzzlecommand = {timing = {matchtimer=0, collectnow_usingmultiplier=multiplier}} -- note: the game's use of the multiplier is actually ignored since the script has decided to control the scoring
			local flyups = {}
			if multiplier >1.99 then -- send up duplicated flyups to celebrate the multiplier
				local currentPuzzle = puzz["cells"]
				for i=1,#currentPuzzle do
					local ct = currentPuzzle[i]
					for j=1,#ct do
						local cell = ct[j]
						if cell["matched"] then
							for k=1,multiplier-1 do
								flyups[#flyups+1] = {row=j-1,col=i-1,type=cell["type"]}
							end
						end
					end
				end
				puzzlecommand["flyups"] = flyups
			end
			dirty = true
			SetPuzzle(puzzlecommand)
			puzz = GetPuzzle()
		end
		local numWhitesCollected = CollectAllBottomRowWhiteBlocks(puzz, defaultPointsPerWhite*whitesmultiplier)
		local didLowerBlocks = FullyLowerPuzzleBlocks(puzz)
		if numWhitesCollected>0 or didLowerBlocks then
			SetPuzzle(puzz)
		end

		looping = dirty or didLowerBlocks or (numWhitesCollected>0)

		whitesCollected = whitesCollected + numWhitesCollected
		blocksCollected = blocksCollected + matchSize

		iterations = iterations + 1
	end

	if iterations > 99 then
		print("bug, collectallmatches loop went infinite")
	end

	additiveMatchMultiplier = 0

	return whitesCollected + blocksCollected
end

function Paint(colorid)
	SetPuzzle{timing={addallinflightblocksnow=true}}
	local puzz = GetPuzzle()
	local currentPuzzle = puzz["cells"]
	for i=1,#currentPuzzle do
		local ct = currentPuzzle[i]
		for j=1,#ct do
			local cell = ct[j]
			if cell["type"] >= 0 then
				cell["type"] = colorid
			end
		end
	end

	puzz["timing"] = {matchtimer=0} -- delay match collection
	SetPuzzle(puzz)
end

function Undo()
	if erasedtype >= 0 then
		local puzz = GetPuzzle()
		local currentPuzzle = puzz["cells"]
		local newblocks = {}
		local vehiclestrafe = gPlayerStrafe

		local flightTime = 0.3
		local celebrationWhitesAirTime = timeSoFar - lastTimeCelebrationWhitesLaunched
		local celebrationWhitesInFlight = false
		if celebrationWhitesAirTime < celebrationWhitesFlightTime then -- make sure blocks hit just after multiplier don't get under the celebration whites in the puzzle grid
			flightTime = flightTime + (celebrationWhitesFlightTime - celebrationWhitesAirTime)
			celebrationWhitesInFlight = true
		end

		local pendingBlockCounts = puzz["pendingblockcounts"]
		local freeCellsPerCol = {}

		for i=1,#currentPuzzle do -- col (1-3)
			freeCellsPerCol[i] = 0
			local ct = currentPuzzle[i]
			for j=1,#ct do -- row (1-7)
				local cell = ct[j]
				if cell["type"] < 0 then -- empty cell
					freeCellsPerCol[i] = freeCellsPerCol[i] + 1
				end
			end
		end

		for i=1,#currentPuzzle do -- col (1-3)
			freeCellsPerCol[i] = freeCellsPerCol[i] - pendingBlockCounts[i]
			local ct = currentPuzzle[i]
			for j=1,#ct do -- row (1-7)
				if erasedcolcounts[i] > 0 and freeCellsPerCol[i] > 0 then
					newblocks[#newblocks+1] = {
						type=erasedtype,
						collision_strafe = vehiclestrafe,
						puzzle_col = i-1,
						transitionseconds = flightTime,
						add_top = celebrationWhitesInFlight
					}

					erasedcolcounts[i] = erasedcolcounts[i] - 1
					freeCellsPerCol[i] = freeCellsPerCol[i] - 1
				end
			end
		end

		local puzzlechanges = {}
		puzzlechanges["newblocks"] = newblocks
		SetPuzzle(puzzlechanges)

		erasedtype = -1
	end
end

erasedcolcounts = {}
erasedtype = -1

function Erase(eraseType)
	SetPuzzle{timing={addallinflightblocksnow=true}}
	local puzz = GetPuzzle()
	local currentPuzzle = puzz["cells"]

	local preverasedcolcounts = deepcopy(erasedcolcounts)
	local numErased = 0

	for i=1,#currentPuzzle do -- i is column index (1-3)
		erasedcolcounts[i] = 0
		local ct = currentPuzzle[i]
		ecells[i] = ecells[i] or {}
		local et = ecells[i]
		for j=1,#ct do -- j is row index (1-7)
			local cell = ct[j]
			et[j] = et[j] or {}
			local ecell = et[j]
			if cell["type"] == eraseType then
				ecell["type"] = eraseType
				cell["type"] = -1
				erasedcolcounts[i] = erasedcolcounts[i] + 1
				numErased = numErased + 1
			else
				ecell["type"] = -1
			end
		end
	end

	if numErased < 1 then --don't clear the undo cache if nothing was erased
		erasedcolcounts = preverasedcolcounts
	else
		erasedtype = eraseType
	end

	local timing = {matchtimer=0}

	local puzzlechanges = {}
	puzzlechanges["timing"] = timing
	puzzlechanges["cells"] = currentPuzzle
	SetPuzzle(puzzlechanges)
end

Q = Q or {}
function Qblock(block)
	if not Q[Qsize] then --if the Q is not full
		for i=Qsize,2,-1 do
			Q[i] = Q[i-1]
			if Q[i] then
				SendCommand{command="ChangeTrafficBlockCloneType", name="Qblock"..i, param={blocktype=Q[i].type, powerupname=Q[i].powerupname}}
				SendCommand{command="Show", name="Qblock"..i}
			else
				SendCommand{command="Hide", name="Qblock"..i}
			end
		end

		--add the new block to the front of the queue
		Q[1] = deepcopy(block)
		SendCommand{command="ChangeTrafficBlockCloneType", name="Qblock"..1, param={blocktype=block.type, powerupname=block.powerupname}}
		SendCommand{command="Show", name="Qblock"..1}
	end
end

function dQblock()
	if Q[1] then
		if (Q[1].type < 100) or Q[1].type==whiteblocktype then
			local playerLane = 0;
			if gPlayerStrafe>half_lanespace then playerLane = 1
			elseif gPlayerStrafe<-half_lanespace then playerLane=-1 end

			local flightTime = 0.3
			local celebrationWhitesAirTime = timeSoFar - lastTimeCelebrationWhitesLaunched
			if celebrationWhitesAirTime < celebrationWhitesFlightTime then -- make sure blocks hit just after multiplier don't get under the celebration whites in the puzzle grid
			flightTime = flightTime + (celebrationWhitesFlightTime - celebrationWhitesAirTime)
			end

			local newblocks = {}
			newblocks[1] = {
				type=Q[1].type,
				collision_strafe = gPlayerStrafe,
				puzzle_col = playerLane+1,
				transitionseconds = flightTime,
				add_top = true,
				powerupname = Q[1].powerupname -- this can be nil for storming non-powerups
			}
			local puzzlechanges = {}
			puzzlechanges["newblocks"] = newblocks
			SetPuzzle(puzzlechanges)
		else
			FirePowerup(Q[1].powerupname)
		end

		for i=1,Qsize do
			Q[i] = Q[i+1]
			if Q[i] then
				SendCommand{command="ChangeTrafficBlockCloneType", name="Qblock"..i, param={blocktype=Q[i].type, powerupname=Q[i].powerupname}}
				SendCommand{command="Show", name="Qblock"..i}
			else --now empty, hide it
				SendCommand{command="Hide", name="Qblock"..i}
			end
		end
	end
end

function Storm(type, countpercolumn, powerupname, transitiontime, iscelebrationwhites)
	local puzz = GetPuzzle()
	local currentPuzzle = puzz["cells"]
	local newblocks = {}
	local vehiclestrafe = gPlayerStrafe
	local droptime = transitiontime or .3

	local flightTime = droptime
	local celebrationWhitesInFlight = false
	if not iscelebrationwhites then -- unless this storm was fired as a storm of celebration whites
		local celebrationWhitesAirTime = timeSoFar - lastTimeCelebrationWhitesLaunched
		if celebrationWhitesAirTime < celebrationWhitesFlightTime then -- make sure blocks hit just after multiplier don't get under the celebration whites in the puzzle grid
			flightTime = flightTime + (celebrationWhitesFlightTime - celebrationWhitesAirTime)
			celebrationWhitesInFlight = true
		end
	end

	local pendingBlockCounts = puzz["pendingblockcounts"]
	local freeCellsPerCol = {}

	for i=1,#currentPuzzle do -- i is column index (1-3)
		freeCellsPerCol[i] = 0
		local ct = currentPuzzle[i]
		for j=1,#ct do -- j is row index (1-7)
			local cell = ct[j]
			if cell["type"] < 0 then -- only throw to empty cells (storms never overfill)
				freeCellsPerCol[i] = freeCellsPerCol[i] + 1
			end
		end
	end

	for i=1,#currentPuzzle do -- col (1-3)
		freeCellsPerCol[i] = freeCellsPerCol[i] - pendingBlockCounts[i]
		local numThrownIntoThisColumn = 0
		local ct = currentPuzzle[i]
		for j=1,#ct do -- j is row index (1-7)
			if (numThrownIntoThisColumn < countpercolumn) and freeCellsPerCol[i] > 0 then
				newblocks[#newblocks+1] = {
					type=type,
					collision_strafe = vehiclestrafe,
					puzzle_col = i-1,
					transitionseconds = flightTime,
					add_top = celebrationWhitesInFlight,
					powerupname = powerupname -- this can be nil for storming non-powerups
				}

				numThrownIntoThisColumn = numThrownIntoThisColumn + 1
				freeCellsPerCol[i] = freeCellsPerCol[i] -1
			end
		end
	end

	local timing = {matchtimer=0}

	local puzzlechanges = {}
	puzzlechanges["timing"] = timing
	puzzlechanges["newblocks"] = newblocks
	SetPuzzle(puzzlechanges)
end

function SortPuzzle()
	local puzz = GetPuzzle()
	local currentPuzzle = puzz["cells"]

	local celltypes = {}
	for i=1,#currentPuzzle do -- i is column index (1-3)
		local ct = currentPuzzle[i]
		for j=1,#ct do -- j is row index (1-7)
			local cell = ct[j]
			table.insert(celltypes, cell["type"])
		end
	end

	table.sort(celltypes, function(a,b) return a > b end)

	local arp = false --track if the current row pass is asc or dsc
	local currentType = 0
	local ct = currentPuzzle[1]
	local cell = ct[1]
	local ti = 1
	for j=1, #ct do -- j is row index (1-7)
		for i=(fif(arp,1,#currentPuzzle)),(fif(arp,#currentPuzzle,1)),(fif(arp,1,-1)) do -- i is column index (1-3)
			ct = currentPuzzle[i]
			cell = ct[j]
			cell["type"] = celltypes[ti]
			ti = ti + 1
		end
		arp = not arp --flip this boolean
	end

	local timing = {matchtimer=0}

	local puzzlechanges = {}
	puzzlechanges["timing"] = timing
	puzzlechanges["cells"] = currentPuzzle
	SetPuzzle(puzzlechanges)
end

function randsort(tab)
	local n, order, res = #tab, {}, {}
	 
	for i=1,n do order[i] = { rnd = math.random(), idx = i } end
	table.sort(order, function(a,b) return a.rnd < b.rnd end)
	for i=1,n do res[i] = tab[order[i].idx] end
	return res
end

function ShufflePuzzle()
	local puzz = GetPuzzle()
	local currentPuzzle = puzz["cells"]

	--local availableCells = {}
	local availableTypes = {}
	for i=1,#currentPuzzle do -- i is column index (1-3)
		local ct = currentPuzzle[i]
		for j=1,#ct do -- j is row index (1-7)
			local cell = ct[j]
			table.insert(availableTypes, cell["type"])
		end
	end

	availableTypes = randsort(availableTypes)

	if #availableTypes > 2 then
		local shuffledPuzzle = deepcopy(currentPuzzle)
		local ai = 1
		for i=1,#currentPuzzle do -- i is column index (1-3)
			local ct = currentPuzzle[i]
			for j=1,#ct do -- j is row index (1-7)
				local cell = ct[j]
				cell["type"] = availableTypes[ai]
				ai = ai + 1
			end
		end

		local timing = {matchtimer=0}

		local puzzlechanges = {}
		puzzlechanges["timing"] = timing
		puzzlechanges["cells"] = currentPuzzle
		SetPuzzle(puzzlechanges)
	end
end

function S1_StartsWith_S2(haystack, needle)
  return string.sub(haystack, 1, string.len(needle)) == needle
end

lastTimeCelebrationWhitesLaunched = lastTimeCelebrationWhitesLaunched or 0
celebrationWhitesFlightTime = 1.0

function FirePowerup(powerupname)
	if S1_StartsWith_S2(powerupname, "paint") then
		Paint(tonumber(string.sub(powerupname, 6)))
		PlaySound{name="paint"}

	elseif S1_StartsWith_S2(powerupname, "x") then
		SetPuzzle{timing={addallinflightblocksnow=true}} -- make sure anything currently in-flight hits the grid (and gets collected) before the celebration whites launch
		local multiplier = tonumber(string.sub(powerupname, 2))
		local chainMultiplier = GetChainMultiplier_FromChainCount(chainCount)
		local compositeMultiplier = multiplier + chainMultiplier
		local numCollected = CollectAllMatches(compositeMultiplier, multiplier)
		ClearPuzzle()
		local numWhitesStormedPerColumn = math.max(multiplier, math.floor((numCollected / puzzlecolcount)+.5))
		local secondstopuzzle = celebrationWhitesFlightTime
		lastTimeCelebrationWhitesLaunched = timeSoFar
		Storm(whiteblocktype, numWhitesStormedPerColumn, "whiteblock", secondstopuzzle, true) -- whitestorm

	elseif S1_StartsWith_S2(powerupname, "storm") then
		local btype = tonumber(string.sub(powerupname, 6))
		local powerupname = nil
		if btype == whiteblocktype then
			powerupname = "whiteblock"
		end
		local numPerColumn = 3
		Storm(btype, numPerColumn, powerupname)
		PlaySound{name="storm"}

	elseif powerupname=="sort" then
		SortPuzzle()
	end
end

function IsInShoulderLanes(strafe)
	local maxlane = puzzlecolcount / 2
	if strafe~=nil and ((strafe > lanespace * maxlane) or (strafe < lanespace * -maxlane)) then
		return true
	else
		return false
	end
end

hitGrey = false
hasCollided = hasCollided or false
highestNodeCollidedAt = highestNodeCollidedAt or 0 -- used to make sure two powerups or blocks at the same track location are not both collected
blockColorCollectedTotals = blockColorCollectedTotals or {}
function Collide(player)
	local strafe = player.pos[1]
	local tracklocation = player.tracklocation
	local playerLane = 0
	--if shoulderlanes and ((strafe > lanespace * 1.5) or (strafe < lanespace * -1.5)) then
	if shoulderlanes and IsInShoulderLanes(strafe) then
		playerLane = 9999 -- will not hit anything
	else
		if strafe > 0 then
			if strafe > lanespace then
				playerLane = 2
			else
				playerLane = 1
			end
		else
			if strafe < -lanespace then
				playerLane = -2
			else
				playerLane = -1
			end
		end
	end

	local collisionTolerenceAhead = .1
	local collisionToleranceBehind_colors = 2.1
	local collisionToleranceBehind_greys = .5 -- greys don't get a generous collision window the way colors and powerups do

	local maxRing = iCurrentRing + 2
	local foundFirst = false
	for i=player.prevFirstBlockCollisionTested,#blockNodes do
		if (blocks[i].lane < 0 and player.num==2) or (blocks[i].lane>0 and player.num==1) then
			if not blocks[i].irrelevant then
				if blockNodes[i] <= maxRing then
					if not foundFirst then
						player.prevFirstBlockCollisionTested = i
						foundFirst = true
					end

					local allowCollision = false

					local collisionToleranceBehind = (blocks[i].type == 5) and collisionToleranceBehind_greys or collisionToleranceBehind_colors

					if blockNodes[i] < (tracklocation - collisionToleranceBehind) then
						if blocks[i].collisiontestcount < 1 then
							allowCollision = true -- make sure each block is allowed at least one collision test, no matter how far behind the impact node it is now
						end
						blocks[i].irrelevant = true
					end

					if (blockNodes[i] <= (tracklocation + collisionTolerenceAhead)) and (blockNodes[i] >= (tracklocation - collisionToleranceBehind)) then
						allowCollision = true
					end

					if allowCollision then
						blocks[i].collisiontestcount = blocks[i].collisiontestcount + 1
						if not blocks[i].hidden then
							if (blocks[i].lane == playerLane) and (blocks[i].impactnode > player.highestNodeCollidedAt) then
								hasCollided = true
								player.highestNodeCollidedAt = math.max(player.highestNodeCollidedAt, blocks[i].impactnode)

								blocksToHide[#blocksToHide+1] = i
								blocks[i].hidden = true
								local blockOffset = blockOffsets[i]
								local isPowerup = false
								local collisionType = blocks[i].type
								local powerupname = nil
								if blocks[i].type == 5 then
									hitGrey = true
								elseif blocks[i].type == 124 then
									isPowerup = true
									if longestJump > 6 then
										PlayBuiltInSound{soundType="crowdroar"}
									else
										PlaySound{name="matchlarge"}
									end
								elseif blocks[i].type == whiteblocktype then
									isPowerup = false
									powerupname = "whiteblock"
									collisionType = whiteblocktype
								elseif blocks[i].type >= 100 then
									isPowerup = true
								end

								local tp = {}
								tp["timing"] = {matchtimer=0}

								if (not isPowerup) or (isQing and canQpowerups and (canQpowerups_evenMultipliers or (blocks[i].type < 122))) then
									if isErasing then
										Erase(blocks[i].type)
										PlaySound{name="erase"}
									elseif isQing then
										Qblock(blocks[i])
										PlaySound{name="queue"}
									else
										local flightTime = 0.35
										local celebrationWhitesAirTime = timeSoFar - lastTimeCelebrationWhitesLaunched
										if celebrationWhitesAirTime < celebrationWhitesFlightTime then -- make sure blocks hit just after multiplier don't get under the celebration whites in the puzzle grid
											flightTime = flightTime + (celebrationWhitesFlightTime - celebrationWhitesAirTime)
										end
										local puzzle_col = blocks[i].lane + 2
										if blocks[i].lane > 0 then
											puzzle_col = blocks[i].lane + 1
										end
										tp["newblocks"] = {{type=collisionType, collision_strafe=blockOffset[1], puzzle_col=puzzle_col+pushDirection, add_top=true, transitionseconds=flightTime, shrinkdown=true, powerupname=powerupname}}
									end

									if pushDirection~=0 then
										PlaySound{name="push"}
									end
								else
									FirePowerup(blocks[i].powerupname)
								end

	--							if not isErasing then
								if blockColorCollectedTotals[collisionType] == nil then
									blockColorCollectedTotals[collisionType] = 1
								else
									blockColorCollectedTotals[collisionType] = blockColorCollectedTotals[collisionType] + 1
								end
	--							end

								SetPuzzle(tp)
								SendCommand{command="HoverUp"} -- causes the hovering vehicle to bounce up a bit
							end
						end
					end
				else
					break --stop the loop once we get to a block way past the player
				end
			end
		end
	end
end

function GetPercentPuzzleFilled(countMatchedCellsAsEmpty)
	local puzzle = GetPuzzle()
	local cells = puzzle["cells"]
	local numFilled = 0
	local numCells = 0
	for colnum=1,#cells do
		local col = cells[colnum]
		for rownum=1,#col do
			numCells = numCells + 1
			local cell = col[rownum]
			if cell.type >=0 then
				if not (countMatchedCellsAsEmpty and cell["matched"]) then
					numFilled = numFilled + 1
				end
			end
		end
	end

	return numFilled / numCells
end

function GetNextCollisionStrafe() -- figure out which lane the minion should be in
	for i=player.prevFirstBlockCollisionTested,#blockNodes do
		if not blocks[i].tested then
			return blocks[i].lane * lanespace
		end
	end

	return 0
end

lastShuffleTime = lastShuffleTime or 0.01
isShuffling = false
function ShuffleCo()
	isShuffling = true

	PlaySound{name="shuffle"}

	--local timing = {matchtimer=0, collectnow_usingmultiplier=1} -- collect existing matches immediately before shuffling
	--local puzzlechanges = {}
	--puzzlechanges["timing"] = timing
	--SetPuzzle(puzzlechanges)
	--waitSeconds(.2)

	ShufflePuzzle()
	lastShuffleTime = timeSoFar
	--waitSeconds(1.2) -- thy must wait this long before attempting another shuffle
	isShuffling = false
end

lastSortTime = lastSortTime or 0.01
isSorting = false
function SortCo()
	isSorting = true


	--local timing = {matchtimer=0, collectnow_usingmultiplier=1} -- collect existing matches immediately before sorting
	--local puzzlechanges = {}
	--puzzlechanges["timing"] = timing
	--SetPuzzle(puzzlechanges)

	--waitSeconds(.2)
	SortPuzzle()
	lastSortTime = timeSoFar
	--waitSeconds(1.2) -- thy must wait this long before attempting another shuffle
	isSorting = false
end

function DoSort()
	if timeSoFar > 6 then
		if not isSorting then
			local puzz = GetPuzzle()
			local currentPuzzle = puzz["cells"]
			local filledCellCount = 0
			for i=1,#currentPuzzle do -- i is column index (1-3)
				local ct = currentPuzzle[i]
				for j=1,#ct do -- j is row index (1-7)
					local cell = ct[j]
					if cell["type"] >= 0 then
						filledCellCount = filledCellCount + 1
					end
				end
			end

			if filledCellCount > 1 then
				local co = coroutine.create(SortCo)
	    		return coroutine.resume(co)
	    	end
		end
	end
end

function DoShuffle()
	if timeSoFar > 6 then
		if not isShuffling then
			local puzz = GetPuzzle()
			local currentPuzzle = puzz["cells"]
			local filledCellCount = 0
			for i=1,#currentPuzzle do -- i is column index (1-3)
				local ct = currentPuzzle[i]
				for j=1,#ct do -- j is row index (1-7)
					local cell = ct[j]
					if cell["type"] >= 0 then
						filledCellCount = filledCellCount + 1
					end
				end
			end

			if filledCellCount > 1 then
				local co = coroutine.create(ShuffleCo)
	    		return coroutine.resume(co)
	    	end
		end
	end
end

timeSoFar = timeSoFar or 0.01

function ProcessAction(action, justPressed)
	if action=="shuffle" then
		if justPressed then
			DoShuffle()
		end
	elseif action=="sort" then
		if justPressed then
			DoSort()
		end
	elseif action=="pushleft" then
		pushDirection = -1
	elseif action=="pushright" then
		pushDirection = 1
	elseif action=="erase" then
		isErasing = true
	elseif action=="undo" then
		if justPressed then
			Undo()
		end
	elseif action=="Q" then
		if not Q[Qsize] then
			isQing = true
		end
	elseif action=="dQ" then
		if justPressed then
			dQblock()
		end
	end
end

numActiveRumbleForTimeCoroutines = numActiveRumbleForTimeCoroutines or 0
function RumbleForTimeCo(left,right,duration)
	numActiveRumbleForTimeCoroutines = numActiveRumbleForTimeCoroutines + 1
	--print("send rumble to game")
	RumbleActiveGamepad(left,right)
	waitSeconds(duration)
	if numActiveRumbleForTimeCoroutines == 1 then
		--print("end rumble")
		RumbleActiveGamepad(0,0) -- end the rumbling unless another rumble function started while this was running
	end
	numActiveRumbleForTimeCoroutines = math.max(0, numActiveRumbleForTimeCoroutines - 1)
end

function PassiveCo() -- run this character's passive ability
	local genPowerups = {}
	if passive=="generatepowerup" then
		--build a list of powerups that can possibly be generated
		for key,value in pairs(powerups) do
			if value.cangenerate then
				genPowerups[#genPowerups+1] = key
			end
		end
	end

	while true do -- loop forever
		--wait the required amount of time
		if (type(passiveInterval) == "table") then
			waitSeconds(math.random(passiveInterval[1], passiveInterval[2]))
		else
			waitSeconds(passiveInterval)
		end

		--activate the character's passive power again
		if passive=="generatepowerup" then
			-- note: any type >= 100 here will signify that it is some powerup. The name is used to identify it
			Qblock{type=100, powerupname=genPowerups[math.random(1,#genPowerups)]}
		end
	end
end



mouseSpeed = .35
cosmeticStrafeSpeed = 15
function UpdatePlayer(player, input, dt, vehiclehoverheight)
	--print("Vertical:"..input["Vertical"])
	--player.pos[2] = 0
	local mouseInput = input["mouse"]
	local mouseHorizontal = mouseInput["x"]
	local keyHorizontal = input["Horizontal"]
	--if (player.num==2) and (keyHorizontal==0) then
	--	keyHorizontal = player1_rightStick
	--end

	if(player.controller=="mouse") then
		if keyHorizontal ~= 0 then
			player.controller = "key"
		end
	elseif mouseHorizontal~=0 then
		if player.num==1 then -- only player1 has the option of mouse control
			player.controller = "mouse"
		end
	end

	if player.controller=="mouse" then
		if dt>0 then --don't move when the game is paused
			--player.pos[1] = math.max(-7.5, math.min(-1, player.pos[1] + mouseHorizontal * mouseSpeed))
			player.pos[1] = math.min(7.5, math.max(1, player.pos[1] + mouseHorizontal * mouseSpeed))
		end

		player.posCosmetic[1] = player.pos[1]
	else --key mode (keyboard or gamepad)
		local playerLane = 0
		if keyHorizontal > 0.5 then playerLane = 1
		elseif keyHorizontal < -0.5 then playerLane = -1 end

		if player.num==2 then playerLane = playerLane - 2
		elseif player.num==1 then playerLane = playerLane + 2 end

		player.pos[1] = lanespace * playerLane
    	if player.pos[1] < 0 then player.pos[1] = player.pos[1] + half_lanespace
    	else player.pos[1] = player.pos[1] - half_lanespace end

		player.posCosmetic[1] = player.posCosmetic[1] + cosmeticStrafeSpeed * dt * (player.pos[1] - player.posCosmetic[1])
	end

	player.posCosmetic[2] = vehiclehoverheight * .2

	SendCommand{command="SetTransform", name=player.uniqueName, param={pos=player.posCosmetic}}

	Collide(player)

	player.prevInput = input
end



isPaused = false
prevInput1 = false
prevInput2 = false
framecount = framecount or 0
startedPassiveCoroutine = false
lmbPrevPressTime = lmbPrevPressTime or 0
rmbPrevPressTime = rmbPrevPressTime or 0
lmbAvailable = lmbAvailable or true
rmbAvailable = rmbAvailable or true
shoulderDrivingDuration = shoulderDrivingDuration or 0
gamepadDetected = false
function Update(dt, tracklocation, playerstrafe, input, vehiclehoverheight) --called every frame
	isPaused = dt == 0
	gPlayerStrafe = playerstrafe

	timeSoFar = timeSoFar + dt

	iCurrentRing = math.floor(tracklocation)
	local playersInput = input["activedevice"] -- this mode is single-player, so we only need to respond to the currently-active device
	local mouseInput = input["mouse"]
	local multiPlayersInput = input["players"]

	if isPaused then
		playersInput = gPrevPlayerInput
		mouseInput = pPrevMouseInput
		multiPlayersInput = gPrevMultiPlayersInput
	end

	local prevPushDir = pushDirection
	pushDirection = 0
	local prevIsErasing = isErasing
	isErasing = false
	local prevIsQing = isQing
	isQing = false

	local input1 = playersInput["button1"] or mouseInput["LMB"] or playersInput["LeftBumper"] or (playersInput["LeftTrigger"] > 0)
	local input2 = playersInput["button2"] or mouseInput["RMB"] or playersInput["RightBumper"] or (playersInput["RightTrigger"] > 0)

	if canPush and (not shoulderlanes) then -- can't use the right stick for pushing if it is needed to get out to shoulder lanes
		if playersInput["Horizontal2"] < -.5 then
			input1 = true
		elseif playersInput["Horizontal2"] > .5 then
			input2 = true
		end
	end

	local prevLmbAvailable = lmbAvailable
	lmbAvailable = (timeSoFar - lmbPrevPressTime) >= lmbInterval
	local prevRmbAvailable = rmbAvailable
	rmbAvailable = (timeSoFar - rmbPrevPressTime) >= rmbInterval

	if shoulderTriggersLmbPowerContinuously then
		if IsInShoulderLanes(playerstrafe) then
			if shoulderDrivingDuration >= shoulderTriggerRequiredStartTime then
				input1 = true
				prevInput1 = false -- pretend it wasn't pressed last frame, in case it was. This way the power will fire repeatedly from the shoulder
			end
			shoulderDrivingDuration = shoulderDrivingDuration + dt
		else
			shoulderDrivingDuration = 0
		end
	end

	if playersInput ~= nil then
		if input1 then
			local justPressed = false
			if not prevInput1 then
				if lmbAvailable then
					justPressed = true
					lmbPrevPressTime = timeSoFar
				end
			end
			ProcessAction(lmb, justPressed)
		end

		--handle right mouse button
		if input2 then
			local justPressed = false
			if not prevInput2 then
				if rmbAvailable then
					justPressed = true
					rmbPrevPressTime = timeSoFar
				end
			end
			ProcessAction(rmb, justPressed)
		end
	end

	if prevLmbAvailable ~= lmbAvailable then
		if lmb=="shuffle" then
			SendCommand{command=fif(lmbAvailable,"Hide","Show"), name="Vegas"}
		end
	end

	if prevIsQing ~= isQing then
		SendCommand{command=fif(isQing, "Show", "Hide"), name="Scoop"}
	end

	if prevIsErasing ~= isErasing then
		SendCommand{command=fif(isErasing, "Show", "Hide"), name="Eraser"}
	end

	if pushDirection ~= prevPushDir then
		if prevPushDir ~= 0 then
			if prevPushDir < 1 then
				SendCommand{command="Hide", name="PushLeft"}
			else
				SendCommand{command="Hide", name="PushRight"}
			end
		end

		if pushDirection ~= 0 then
			if pushDirection < 1 then
				SendCommand{command="Show", name="PushLeft"}
			else
				SendCommand{command="Show", name="PushRight"}
			end
		end
	end

	hitGrey = false

	blocksToHide = {}



	--local adinput = input["activedevice"]
	--print(adinput["name"])

	local player1_input = multiPlayersInput[1]
	local player2_input = multiPlayersInput[2]

	if player1_input["isGamepadInputThisFrame"] then
		player2_input["Horizontal"] = player2_input["Horizontal"] + player1_input["Horizontal"];
		player1_input["Horizontal"] = player1_input["Horizontal2"];
	end

	if player2_input["isGamepadInputThisFrame"] then
		player1_input["Horizontal"] = player1_input["Horizontal"] + player2_input["Horizontal2"];
	end

	--local player1_rightStick = player1_input["Horizontal2"]

	for i=1,#players do
		players[i].tracklocation = tracklocation
		UpdatePlayer(players[i], multiPlayersInput[i], dt, vehiclehoverheight)
	end
	--Collide(playerstrafe, tracklocation)





	if #blocksToHide > 0 then
		local pitch = 1 + 2 * GetPercentPuzzleFilled(false)
		PlaySound{name=fif(hitGrey,"hitgreypro", "hit"),pitch=pitch} -- PlaySound{name="hit",pitch=pitch,volume=1,loopseconds=0}
		HideTraffic(blocksToHide)
		local hiddenBlockID = blocksToHide[1]
		local blockToHide = blocks[hiddenBlockID]
		local blockType = blockToHide.type
		local isWhiteBlock = blockType == whiteblocktype

		local hidingPowerup = false

		if blockToHide.powerupname ~= nil then
			local pu = powerups[blockToHide.powerupname]
			if pu.blockcolorid ~= nil then
				blockType = pu.blockcolorid
			end
		end

		local duration = .3
		local sizescaler = 5
		if (blockType>100) and not isWhiteBlock then
			duration = 1.2
			sizescaler = 25
			hidingPowerup = true
		end

		FlashAirDebris{colorID=blockType, duration = duration, sizescaler = sizescaler}

		if hasCollided then
			local co = coroutine.create(RumbleForTimeCo)
			local left = fif(hidingPowerup, .4, 0) -- the left moter is lower frequency and only used for powerups here
			local right = fif(hidingPowerup, .6, .4)
			local duration = fif(hidingPowerup, 0.6,0.2)
			--print("starting rumble co")
		    return coroutine.resume(co, left, right, duration)
		end
	end

	if (iCurrentRing>1) and not startedPassiveCoroutine then
		startedPassiveCoroutine = true
		if passive ~= nil then
			--print("starting passiveCo"..tostring(startedPassiveCoroutine))
			local co = coroutine.create(PassiveCo)
		    return coroutine.resume(co)
		end
	end

	gPrevPlayerInput = playersInput
	pPrevMouseInput = mouseInput
	gPrevMultiPlayersInput = multiPlayersInput

	prevInput1 = input1
	prevInput2 = input2

	framecount = framecount + 1
end

hasParentedQblocks = false
lastTimeWhitesCollected = lastTimeWhitesCollected or 0
--Display mode powers here
function LateUpdate(dt, tracklocation, playerstrafe, input, vehiclehoverheight)
	if puzzleColors then --if we've gotten colors from the skin
		local puzz = GetPuzzle()
		local currentPuzzle = puzz["cells"]

		if canUndo then
			local rowLocations = GetPuzzleRowLocations()
			local commands = {}
			for i=1,#currentPuzzle do  -- i is column index (1-3)
				local ct = currentPuzzle[i]
				local markersThisCol = 0
				if erasedtype >= 0 then
					markersThisCol = erasedcolcounts[i]
				end
				for j=1,#ct do -- j is row index (1-7)
					local cell = ct[j]
					local ctype = cell["type"]
					local n = "undomarker"..i..j
					if (ctype < 0) and (markersThisCol > 0) then
						commands[#commands+1] = {name=n, command="ChangeTrackNodeOffset", param={offset=rowLocations[j]}}
						commands[#commands+1] = {name=n, command="ChangeShaderColors", param={_Color=puzzleColors[erasedtype+1]}}
						commands[#commands+1] = {name=n, command="Show"}
						markersThisCol = markersThisCol - 1
					else
						commands[#commands+1] = {name=n, command="Hide"}
					end
				end
			end
			SendCommands(commands)
		end

		if ((timeSoFar - lastTimeWhitesCollected) > .5) and ((timeSoFar - lastShuffleTime) > .5) then
			local numWhitesCollected = CollectAllBottomRowWhiteBlocks(puzz) -- collect whites. Note that they don't benefit from the chain bonus
			if numWhitesCollected>0 then --puzzle was changed as white blocks were removed
				SetPuzzle(puzz)
			end
		end
	end

	if pushDirection==1 then
		SendCommand{command="SetTransform", name="PushRight", param={pos={playerstrafe, vehiclehoverheight, 0}}}
	elseif pushDirection==-1 then
		SendCommand{command="SetTransform", name="PushLeft", param={pos={playerstrafe, vehiclehoverheight, 0}}}
	end

	if isErasing then
		SendCommand{command="SetTransform", name="Eraser", param={pos={playerstrafe, vehiclehoverheight, 0}}}
	end

	if (iCurrentRing > 1) and not hasParentedPowerMarkers then
		if canShuffle then
			SendCommand{command="SetParent", name="Vegas", param={parent="builtin_vehicle"}}
		end
		if canQ then
			SendCommand{command="SetParent", name="Scoop", param={parent="builtin_vehicle"}}
		end
		hasParentedPowerMarkers = true
	end

	if Qsize > 0 then
		for i=1,Qsize do
			SendCommand{command="SetTransform", name="Qblock"..i, param={pos={0, .6, -.7-(i*.4)}}}
		end

		if (iCurrentRing > 1) and not hasParentedQblocks then --do this here instead of right as the skin has loaded or else they will become part of the vehicle's reflection
			print("parenting q blocks")
			for i=1,Qsize do
				SendCommand{command="SetParent", name="Qblock"..i, param={parent="builtin_vehicle"}}
				SendCommand{command="Hide", name="Qblock"..i}
			end
			hasParentedQblocks = true
		end
	end
end

function OnRequestFinalScoring()
	CollectAllMatches(1,1) -- collect ALL matches (including gravity matches and gravity whites)

	local cleanFinishBonus = 0
	local percentPuzzleFilledAndUnmatched = GetPercentPuzzleFilled(true)
	if percentPuzzleFilledAndUnmatched == 0 then
		cleanFinishBonus = math.floor(score * cleanFinishBonusScaler)
	end

	local seeingRedBonus = 0
	local percentRedBlocksCollected = 0
	if (blockColorCollectedTotals[3] ~= nil) and (blockColorTotals[3] ~= nil) then
		percentRedBlocksCollected = blockColorCollectedTotals[3] / blockColorTotals[3]
	end
	if percentRedBlocksCollected >= seeingRedThreshold then
		seeingRedBonus = math.floor(score * seeingRedBonusScaler)
	end

	local butterNinjaBonus = 0
	local percentYellowBlocksCollected = 0
	if (blockColorCollectedTotals[2] ~= nil) and (blockColorTotals[2] ~= nil) then
		percentYellowBlocksCollected = blockColorCollectedTotals[2] / blockColorTotals[2]
	end
	if percentYellowBlocksCollected >= butterNinjaThreshold then
		butterNinjaBonus = math.floor(score * butterNinjaBonusScaler)
	end

	local largestMatchBonus = math.floor(score * largestMatch * 0.01)

	return {
		rawscore = score,
		bonuses = {
			"Left Points:"..format_num(players[1].points,0),
			"Right Points:"..format_num(players[2].points,0),
			"Match"..largestMatch..":"..format_num(largestMatchBonus,0),
			"Clean Finish:"..format_num(cleanFinishBonus,0),
			"Butter Ninja:"..format_num(butterNinjaBonus,0),
			"Seeing Red:"..format_num(seeingRedBonus,0)
		},
		finalscore = score + cleanFinishBonus + largestMatchBonus + butterNinjaBonus + seeingRedBonus
	}
end