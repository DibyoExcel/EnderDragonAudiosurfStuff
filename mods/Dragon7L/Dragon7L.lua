function fif(test, if_true, if_false)
	if test then return if_true else return if_false end
  end
  
  -- =========================================================================
  -- LANE CONFIGURATION VARIABLE
  -- =========================================================================
  local totalLanes = 7 -- Change this value (e.g., 3, 5, 7, 9) to adjust lane count
  -- =========================================================================
  
  local maxLaneIndex = math.floor(totalLanes / 2)
  
  calcAntiJumps = false
  randomizeblocktypes = false
  
  GameplaySettings{
	  maxstrafe = maxLaneIndex * 3,
	  usepuzzlegrid = true,
	  puzzlerows = 10,
	  puzzlecols = totalLanes,
	  greypercent = 0.35,
	  railedblockscanbegrey = true,
	  colorcount = 1,
	  usetraffic = true,
	  automatic_traffic_collisions = false,
	  jumpmode = "none",
	  matchcollectionseconds = 1.5,
	  greyaction = "eraseone",
	  trafficcompression = 0.7,
  
	  -- Track generation settings
	  gravity = -.45,
	  playerminspeed = 0,
	  playermaxspeed = 5,
	  minimumbestjumptime = 2.5,
	  uphilltiltscaler = 3.5,
	  downhilltiltscaler = 3.5,
	  uphilltiltsmoother = 0.025,
	  downhilltiltsmoother = 0.05,
	  useadvancedsteepalgorithm = true,
	  alldownhill = false,
	  puzzleblockfallinterval = .1,
	  blockflight_secondstopuzzle = .25,
	  calculate_antijumps_and_antitraffic = calcAntiJumps
  }
  
  SetSkinProperties{
	  lanedividers = {-(maxLaneIndex - 0.5), (maxLaneIndex - 0.5)},
	  shoulderlines = {-(maxLaneIndex + 0.5), (maxLaneIndex + 0.5)},
	  trackwidth = (totalLanes * 1.5) + 0.5,
	  prefersteep = true
  }
  
  player = {
	  score = 0,
	  prevInput = {},
	  iPrevRing = 0,
	  hasFinishedScoringPrevRing = false,
	  uniqueName = "Player",
	  num = 1,
	  prevFirstBlockCollisionTested = 1,
	  pos = {0,0,0},
	  posCosmetic = {0,0,1.5},
	  controller = "mouse",
	  points = 0
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
	  else
		  copy = orig
	  end
	  return copy
  end
  
  function CompareJumpTimes(a,b)
	  return a.jumpairtime > b.jumpairtime
  end
  
  function CompareAntiJumpTimes(a,b)
	  return a.antiairtime > b.antiairtime
  end
  
  powernodes = powernodes or {}
  antinodes = antinodes or {}
  lowestaltitude = 9999
  highestaltitude = -9999
  lowestaltitude_node = 0
  highestaltitude_node = 0
  longestJump = longestJump or -1
  
  track = track or {}
  function OnTrackCreated(theTrack)
	  track = theTrack
	  local songMinutes = track[#track].seconds / 60
  
	  for i=1,#track do
		  track[i].jumpedOver = false
		  track[i].origIndex = i
		  track[i].antiOver = false
	  end
  
	  local strack = deepcopy(track)
	  table.sort(strack, CompareJumpTimes)
  
	  print("POWERNODE calculations. Best air time "..strack[1].jumpairtime)
  
	  for i=1,#strack do
		  if strack[i].jumpairtime >= 2.4 then
			  longestJump = math.max(longestJump, strack[i].jumpairtime)
			  if not track[strack[i].origIndex].jumpedOver then
				  local flightPathClear = true
				  local jumpEndSeconds = strack[i].seconds + strack[i].jumpairtime + 10
				  for j=strack[i].origIndex, #track do
					  if track[j].seconds <= jumpEndSeconds then
						  if track[j].jumpedOver then
							  flightPathClear = false
						  end
					  else
						  break
					  end
				  end
				  if flightPathClear then
					  if #powernodes < (songMinutes + 2) then
						  if strack[i].origIndex > 300 then
							  powernodes[#powernodes+1] = strack[i].origIndex
							  print("added powernode at ring "..strack[i].origIndex)
						  end
						  local extraJumpOverBufferSec = 10
						  jumpEndSeconds = strack[i].seconds + strack[i].jumpairtime + extraJumpOverBufferSec
						  for j=strack[i].origIndex, #track do
							  if track[j].seconds <= jumpEndSeconds then
								  track[j].jumpedOver = true
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
  
	  if calcAntiJumps then
		  table.sort(strack, CompareAntiJumpTimes)
		  for i=1,#strack do
			  if strack[i].antiairtime >= 2.1 then
				  if not track[strack[i].origIndex].antiOver then
					  local flightPathClear = true
					  local jumpEndSeconds = strack[i].seconds + strack[i].antiairtime + 10
					  for j=strack[i].origIndex, #track do
						  if track[j].seconds <= jumpEndSeconds then
							  if track[j].antiOver then
								  flightPathClear = false
							  end
						  else
							  break
						  end
					  end
					  if flightPathClear then
						  if #antinodes < (songMinutes + 1) then
							  if strack[i].origIndex > 300 then
								  antinodes[#antinodes+1] = strack[i].origIndex
							  end
							  jumpEndSeconds = strack[i].seconds + strack[i].antiairtime + 10
							  for j=strack[i].origIndex, #track do
								  if track[j].seconds <= jumpEndSeconds then
									  track[j].antiOver = true
								  else
									  break
								  end
							  end
						  end
					  end
				  end
			  end
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
  
  blocks = blocks or {}
  blockNodes = blockNodes or {}
  blockOffsets = blockOffsets or {}
  traffic = traffic or {}
  
  function OnTrafficCreated(theTraffic)
	  half_lanespace = lanespace / 2
	  traffic = theTraffic
  
	  local minimapMarkers = {}
	  for j=1,#powernodes do
		  local prev = 2
		  for i=prev, #traffic do
			  if traffic[i].chainend >= powernodes[j] then
				  if traffic[i].chainstart <= powernodes[j] then
					  traffic[i].powerupname = "powerpellet"
					  traffic[i].type = 101
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
		  for j=1,#antinodes do
			  local prev = 2
			  for i=prev, #traffic do
				  if traffic[i].chainend >= antinodes[j] then
					  if traffic[i].chainstart <= antinodes[j] then
						  traffic[i].powerupname = "powerpellet"
						  traffic[i].type = 101
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
  
	  math.randomseed(GetMillisecondsSinceStartup())
  
	  local blockIndex = 1
  
	  if not randomizeblocktypes then
		  for i=1,#traffic do
			  traffic[i].origIndex = i
			  traffic[i].span = traffic[i].chainend - traffic[i].chainstart
			  if(traffic[i].type < 100) then
				  traffic[i].type = 6
			  end
		  end
  
		  table.sort(traffic, CompareTrafficStrengthASC)
		  local bound = math.floor(#traffic * .23)
		  for i=1, bound do
			  if(traffic[i].type < 100) then
				  traffic[i].type = 5
			  end
		  end
  
		  table.sort(traffic, CompareTrafficSpanDESC)
		  bound = math.floor(#traffic * .05)
		  for i=1, bound do
			  if(traffic[i].type < 100) then
				  traffic[i].type = 5
			  end
		  end
  
		  table.sort(traffic, CompareTrafficOrigIndexASC)
	  end
  
	  for i = 1, #traffic do
		  local lane = math.random(-maxLaneIndex, maxLaneIndex)
		  if traffic[i].type >= 100 then
			  lane = 0
		  end
		  traffic[i].lane = lane
  
		  if randomizeblocktypes then
			  if(traffic[i].type < 100) then
				  if(math.random()<=0.75) then
					  traffic[i].type = 6
				  else
					  traffic[i].type = 5
				  end
			  end
		  end
  
		  if traffic[i].type >=100 then
			  local powerupImpactNode = traffic[i].impactnode
			  local powerupLane = traffic[i].lane
			  for k=1,#traffic do
				  if (traffic[k].chainstart <= powerupImpactNode) and (traffic[k].chainend >= powerupImpactNode) and (traffic[k].type < 100) then
					  while traffic[k].lane == powerupLane do
						  traffic[k].lane = math.random(-maxLaneIndex, maxLaneIndex)
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
		  if traffic[i].type==5 and (span>0) then
			  caterpillarstart = traffic[i].chainstart
			  caterpillarend = traffic[i].chainend
			  iscaterp = true
		  end
  
		  for j=caterpillarstart, caterpillarend do
			  local block = deepcopy(traffic[i])
			  if iscaterp then
				  block.impactnode = j
				  block.chainstart = block.impactnode
				  block.chainend = block.impactnode
			  end
  
			  if (not iscaterp) or (j==caterpillarstart) or (j==caterpillarend) or (j%3==0) then
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
  
	  local showLowSpot = false
	  if showLowSpot then
		  if (lowestaltitude_node > 300) and (lowestaltitude_node < (#track-300)) then
			  local span = 10
			  local startnode = lowestaltitude_node-math.floor(span/2)
			  local endnode = startnode+span
			  local insertloc = 0
			  for i=2, #traffic do
				  if traffic[i].impactnode > startnode then
					  insertloc = i - 1
					  break
				  end
			  end
			  local allclear=true
			  for i=insertloc, math.min(#traffic, insertloc+span) do
				  if (traffic[i].impactnode >= startnode) and (traffic[i].impactnode <= endnode) then
					  allclear = false
					  break
				  end
			  end
			  if allclear then
				  local j = insertloc
				  for i=startnode, endnode do
					  local la = math.random(-maxLaneIndex, maxLaneIndex)
					  while la == 0 do
						  la = math.random(-maxLaneIndex, maxLaneIndex)
					  end
					  local stra = la * lanespace
					  table.insert(traffic, insertloc, {type=5, impactnode=i, chainstart=i, chainend=i, lane=la, strafe=stra, strength=10})
					  j = j + 1
				  end
			  end
		  end
	  end
  
	  local minnodespace = 4
	  local minsecspace = 0.15
	  local prevtype = blocks[1].type
	  local prevlane = blocks[1].lane
	  local prevseconds = blocks[1].seconds
	  local prevnode = blocks[1].impactnode
	  for i=1, #blocks do
		  local block = deepcopy(blocks[i])
		  local secspan = block.seconds-prevseconds
		  if ((block.impactnode-prevnode) < minnodespace) or (secspan < minsecspace) then
			  if block.type ~= prevtype then
				  while block.lane == prevlane do
					  block.lane = math.random(-maxLaneIndex, maxLaneIndex)
				  end
			  else
				  if secspan < 0.2 then
					  if (block.lane==-1 and prevlane==1) or (block.lane==1 and prevlane==-1) then
						  block.lane = 0
					  end
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
  
	  return blocks
  end
  
  function InsertLoopyLoop(theTrack, apexNode, circumference, invert)
	  if type(invert) ~= "boolean" then invert = false end
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
	  local tiltDeltaOverEntireLoop = fif(invert, 360, -360) + (endOriginalTilt - startTilt)
	  local startPan = theTrack[startRing].pan
	  local pan = startPan
  
	  local panConstant = 40
	  local panRate = panConstant / halfSize
  
	  local panRejoinSpan = math.max(circumference*2, 200)
	  local panRejoinNode = math.min(#theTrack, endRing + panRejoinSpan)
  
	  if (not invert and theTrack[panRejoinNode].pan > startPan) or (invert and theTrack[panRejoinNode].pan < startPan) then
		  panRate = -panRate
	  end
  
	  local midRing = startRing + halfSize + math.ceil(halfSize/10)
  
	  for i = startRing+1, endRing do
		  theTrack[i].tilt = startTilt + tiltDeltaOverEntireLoop * ((i - startRing) / span)
  
		  if i==midRing then panRate = -panRate end
  
		  pan = pan + panRate
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
  
  function InsertCorkscrew(theTrack, startNode, endNode, invert)
	  if type(invert) ~= "boolean" then invert = false end
	  startNode = math.floor(startNode)
	  endNode = math.floor(endNode)
	  if endNode < #theTrack then
		  local cumulativeRoll = theTrack[startNode].roll
		  local rollIncrement = fif(not invert, 540, -540) / (endNode-startNode)
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
  
  function OnRequestTrackReshaping(theTrack)
	  for i=1,#powernodes do
		  local size = 100 + 100 * math.max(1,(theTrack[powernodes[i]].jumpairtime / 10))
		  theTrack = InsertLoopyLoop(theTrack, powernodes[i], size)
		  local randomBool = math.random() > 0.5
		  if i==1 then
			  local startPos = powernodes[i]
			  local quickscrewsize = 75
			  theTrack = InsertCorkscrew(theTrack, startPos, startPos+quickscrewsize, not randomBool)
			  startPos = startPos + quickscrewsize
			  theTrack = InsertCorkscrew(theTrack, startPos, startPos+quickscrewsize, randomBool)
		  else
			  local startPos = powernodes[i]
			  local quickscrewsize = 150
			  local range = 150
			  theTrack = InsertCorkscrew(theTrack, startPos, startPos+quickscrewsize, not randomBool)
			  startPos = startPos + quickscrewsize + range
			  theTrack = InsertCorkscrew(theTrack, startPos, startPos+(quickscrewsize), randomBool)
			  theTrack = InsertLoopyLoop(theTrack, startPos, size, true)
		  end
	  end
  
	  track = theTrack
	  return track
  end
  
  function OnRequestLoadObjects()
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
  
  function OnSkinLoaded()
	  SetCamera{
		  pos={0,totalLanes, -totalLanes},
		  rot={30,0,0}
	  }
  end
  
  score = 0
  oneTimeMatchMultiplier = 1
  function OnPuzzleCollecting()
	  local points = 0
  
	  local puzzle = GetPuzzle()
	  local matchSize = puzzle["matchedcellscount"]
	  if matchSize >= 1 then
		  local cells = puzzle["cells"]
		  for colnum=1,#cells do
			  local col = cells[colnum]
			  for rownum=1,#col do
				  local cell = col[rownum]
				  if cell["matched"] then
					  local cellPoints = 5 * ((cell["type"]+1) * cell["matchsize"])
					  points = points + (cellPoints * oneTimeMatchMultiplier)
				  end
			  end
		  end
  
		  oneTimeMatchMultiplier = 1
  
		  score = score + points
		  SetGlobalScore{score=score,showdelta=true}
		  SetPuzzle{timing={collectnow_usingmultiplier=1, collectioncanautoplaysounds=false}}
		  PlaySound{name="matchsmall"}
	  end
  end
  
  iCurrentRing = 0
  blocksToHide = {}
  stealthy = true
  
  function EatPowerPellet(block, isTheBigOne)
	  local puzz = GetPuzzle()
	  local currentPuzzle = puzz["cells"]
	  local newblocks = {}
	  local vehiclestrafe = gPlayerStrafe
	  for i=1,#currentPuzzle do
		  local ct = currentPuzzle[i]
		  for j=1,#ct do
			  local cell = ct[j]
			  if cell["type"] > 0 then
				  newblocks[#newblocks+1] = {
					  type=cell["type"],
					  collision_strafe = vehiclestrafe,
					  puzzle_col = i-1,
					  transitionseconds = 1,
					  add_top = false
				  }
			  end
		  end
	  end
  
	  local matchSize = puzz["matchedcellscount"]
	  oneTimeMatchMultiplier = 1
	  if matchSize>0 then
		  oneTimeMatchMultiplier = fif(isTheBigOne, 2, 1.5)
	  end
	  local timing = {matchtimer=0, collectnow_usingmultiplier=oneTimeMatchMultiplier}
  
	  local puzzlechanges = {}
	  puzzlechanges["timing"] = timing
	  puzzlechanges["newblocks"] = newblocks
	  SetPuzzle(puzzlechanges)
  end
  
  function EatGhost()
	  local points = 500 + (5000 * GetPercentPuzzleFilled(false))
	  score = score + points
	  SetGlobalScore{score=score,showdelta=true}
  end
  
  hitGrey = false
  function Collide(strafe, tracklocation)
	  -- Mathematically calculate current lane based on player strafe position
	  local playerLane = math.floor((strafe + half_lanespace) / lanespace)
	  playerLane = math.max(-maxLaneIndex, math.min(maxLaneIndex, playerLane))
  
	  local collisionTolerenceAhead = .1
	  local collisionToleranceBehind_colors = 2.1
	  local collisionToleranceBehind_greys = .5
  
	  local maxRing = iCurrentRing + 2
	  local foundFirst = false
	  for i=player.prevFirstBlockCollisionTested,#blockNodes do
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
						  allowCollision = true
					  end
					  blocks[i].irrelevant = true
				  end
  
				  if (blockNodes[i] <= (tracklocation + collisionTolerenceAhead)) and (blockNodes[i] >= (tracklocation - collisionToleranceBehind)) then
					  allowCollision = true
				  end
  
				  if allowCollision then
					  blocks[i].collisiontestcount = blocks[i].collisiontestcount + 1
					  if not blocks[i].hidden then
						  if (blocks[i].lane == playerLane) then
							  blocksToHide[#blocksToHide+1] = i
							  blocks[i].hidden = true
							  local blockOffset = blockOffsets[i]
							  local isPowerup = false
							  if blocks[i].type == 5 then
								  hitGrey = true
							  elseif blocks[i].type == 100 then
								  EatGhost()
								  isPowerup = true
							  elseif blocks[i].type == 101 then
								  isPowerup = true
								  local isTheBigOne = blocks[i].powerRating == 1
								  if isTheBigOne then
									  if longestJump > 6 then
										  PlayBuiltInSound{soundType="crowdroar"}
									  end
								  end
								  EatPowerPellet(blocks[i], isTheBigOne)
							  end
  
							  if not isPowerup then
								  SetPuzzle{newblocks={{type=blocks[i].type, collision_strafe=blockOffset[1], puzzle_col=blocks[i].lane + maxLaneIndex, add_top=true}}}
							  else
								  SetPuzzle{timing={matchtimer=0}}
							  end
							  SendCommand{command="HoverUp"}
						  end
					  end
				  end
			  else
				  break
			  end
		  end
	  end
  end
  
  function GetPercentPuzzleFilled(countMatchedCellsAsEmpty)
	  local puzzle = GetPuzzle()
	  local cells = puzzle["cells"]
	  local numFilled = 0
	  local numCells = 0;
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
  
  function GetNextCollisionStrafe()
	  for i=player.prevFirstBlockCollisionTested,#blockNodes do
		  if not blocks[i].tested then
			  return blocks[i].lane * lanespace
		  end
	  end
  
	  return 0
  end
  
  prevHitAllLanes = true
  prevLeftClick = false
  
  gPlayerStrafe = 0
  function Update(dt, tracklocation, playerstrafe, input)
	  gPlayerStrafe = playerstrafe
	  iCurrentRing = math.floor(tracklocation)
	  hitGrey = false
  
	  blocksToHide = {}
	  Collide(playerstrafe, tracklocation)
  
	  if #blocksToHide > 0 then
		  local pitch = 1 + 2 * GetPercentPuzzleFilled(false)
		  PlaySound{name=fif(hitGrey,"hitgreypro", "hit"),pitch=pitch}
		  HideTraffic(blocksToHide)
		  local hiddenBlockID = blocksToHide[1]
		  local blockType = blocks[hiddenBlockID].type
		  FlashAirDebris{colorID=fif(blockType>100, 5, blockType), duration = fif(blockType>100, 1.2, .15), sizescaler = fif(blockType>100, 25.0, 5.0)}
	  end
  end
  
  function OnRequestFinalScoring()
	  local cleanFinishBonus = 0
	  local percentPuzzleFilledAndUnmatched = GetPercentPuzzleFilled(true)
	  if percentPuzzleFilledAndUnmatched == 0 then
		  cleanFinishBonus = math.floor(score * .1)
	  end
  
	  return {
		  rawscore = score,
		  bonuses = {
			  "Clean Finish:"..cleanFinishBonus
		  },
		  finalscore = score + cleanFinishBonus
	  }
  end