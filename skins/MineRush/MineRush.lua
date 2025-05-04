jumping = PlayerCanJump()
function fif(test, if_true, if_false)
  if test then return if_true else return if_false end
end

hifi = GetQualityLevel() > 2 -- GetQualityLevel returns 1,2,or 3
function ifhifi(if_true, if_false)
  if hifi then return if_true else return if_false end
end
skinvars = GetSkinProperties()
trackWidth = skinvars["trackwidth"]
--trackWidth = fif(jumping, 11.5, 7)
ispuzzle = skinvars.colorcount>1
fullsteep = jumping or skinvars.prefersteep or (not ispuzzle)
track = GetTrack()

SetScene{
	glowpasses = 0,
	glowspread = ifhifi(0.75,0),
	radialblur_strength = ifhifi(.75,0), -- foreground radial blur
--	radialblur_strength = fif(jumping,2,0),
	--environment = "city",
	watertype = 2,
	water = jumping, --only use the water cubes in wakeboard mode
	watertint = {r=255,g=255,b=255,a=234},
	use_intro_swoop_cam = false,
	watertexture = "WaterCubesBlue_BlackTop_WhiteLowerTier.png",--texture used to color the dynamic "digital water" surface
	towropes = jumping,--use the tow ropes if jumping
	airdebris_count = ifhifi(3000,500),
	airdebris_density = ifhifi(50,10),
	airdebris_texture = "area_cloud_effect.png",

--	airdebris_count = ifhifi(fif(jumping, 80000, 100000),1000),
--	airdebris_density = ifhifi(100,2),
--	airdebris_particlesize = fif(jumping, 0.12, 0.09),
--	airdebris_fieldsize = 300,
--	airdebris_layer = 13,

	useblackgrid=false,
	twistmode={curvescaler=1, steepscaler=fif(fullsteep,1,.65)} -- note: "cork" is the same as {curvescaler=1, steepscaler=1} and "cork_flatish" is the same as {curvescaler=1, steepscaler=.4}
}

SetBlockFlashes{
	texture="hit2.jpg"
}

--pixel style...
if hifi then
	radialBlurEffect = BuildMaterial{ -- background radial blur (seen mostly on star air debris trails)
		shader="PostRadialBlur",
		shadersettings={_Amount=.096, _Center={.5,.5,0}}
	}

	AddPostEffect{
		depth="background",
		material = radialBlurEffect
	}


--	pixelateEffectB = BuildMaterial{
--		shader="PostPixelate",
--		shadersettings={_Scale=6}
--	}
--
--	AddPostEffect{
--		depth="background", -- "foreground"
--		material = pixelateEffectB
--	}

	pixelateEffect = BuildMaterial{
		shader="PostLed",
		shadersettings={_Scale=5}
	}

	AddPostEffect{
		depth="background",
		material = pixelateEffect
	}

--	pixelateEffect = BuildMaterial{ -- this looks like a bug to players :(
--		shader="PostPixelateAlphaBlack",
--		shadersettings={_Scale=4}
--	}
--
--	AddPostEffect{
--		depth="topmost_exclusive", -- "topmost_exclusive" means only layers 14 and 15 will be included in this effect. 
--		material = pixelateEffect
--	}

	pixelateEffect = BuildMaterial{ -- this looks like a bug to players :(
		shader="PostLedAlpha",
		shadersettings={_Scale=4}
	}

	AddPostEffect{
		depth="topmost_exclusive", -- "topmost_exclusive" means only layers 14 and 15 will be included in this effect. 
		material = pixelateEffect
	}
end

-- ...or lightbright style
--if hifi then
--	pixelateEffect = BuildMaterial{
--		shader="PostLed",
--		shadersettings={_Scale=5}
--	}
--
--	AddPostEffect{
--		depth="background",
--		material = pixelateEffect
--	}
--end


if not jumping then
	SetBlocks{
		maxvisiblecount = fif(hifi,200,50),
		powerups={

			powerpellet={mesh = "block.obj",
			shader = "VertexColorUnlitTinted",
			scale={x=2.5,y=2.5,z=2.5},
			shadersettings={_Brightness=1.5},
			shadercolors = {_Color="highway"}}
		},
		colorblocks={
			mesh = "block.obj",
			reflect = false,
			--shader = fif(ispuzzle, "Diffuse", "Rim Light"),
			shader = fif(ispuzzle, "Diffuse", "VertexColorUnlitTinted"),
			shadersettings={_Brightness=1.5},
			texture = "colorblock.png",
		    height = 0,
		    float_on_water = false,
		    scale = {1,1,1}
		},
		greyblocks={
			mesh = "block.obj",
			reflect = false,
			shader = "VertexColorUnlitTinted",
			texture = "tnt.png",
			shadersettings={_Brightness=1.5},
			--shadercolors = {_Color="static"},
		}
	}
end

SetPuzzleGraphics{
	usesublayerclone = false,
	puzzlematchmaterial = {shader="Unlit/Transparent",texture="tileMatchingBars.png",aniso=9},
	puzzleflyupmaterial = {shader="VertexColorUnlitTintedAddFlyup",texture="tileMatchingFly.png"},
	puzzlematerial = {shader="VertexColorUnlitTintedAlpha",texture="tilesSquare.png",texturewrap="clamp",aniso=9, usemipmaps="false",shadercolors={_Color={255,255,255,255}}}
}

if jumping then
	SetPlayer{
		--showsurfer = true,
		--showboard = true,
		cameramode = "first_jumpthird",
		--cameramode_air = "third",--"first_jumptrickthird", --start in first, go to third for jumps and tricks

		camfirst={ --sets the camera position when in first person mode. Can change this while the game is running.
			pos={0,2.7,-3.50475},
			rot={20.49113,0,0},
			strafefactor = 1
		},
		camthird={ --sets the two camera positions for 3rd person mode. lerps out towards pos2 when the song is less intense
			pos={0,2.7,-3.50475},
			rot={20.49113,0,0},
			strafefactor = 0.75,
			pos2={0,2.8,-3.50475},
			rot2={20.49113,0,0},
			strafefactorFar = 1},
		surfer={ --set all the models used to represent the surfer
			arms={
				--mesh="arm.obj",
				shader="RimLightHatchedSurfer",
				shadercolors={
					_Color={colorsource="highway", scaletype="intensity", minscaler=3, maxscaler=6, param="_Threshold", paramMin=2, paramMax=2},
					_RimColor={0,63,192}
				},
				texture="FullLeftArm_1024_wAO.png"
			},
			board={
				--mesh="wakeboard.obj",
				shader=ifhifi("RimLightHatchedSurferExternal","VertexColorUnlitTinted"), -- don't use the transparency shader in lofi mode. less fillrate needed that way
				renderqueue=3999,
				shadercolors={ --each color in the shader can be set to a static color, or change every frame like the arm model above
					_Color={colorsource="highway", scaletype="intensity", minscaler=5, maxscaler=5},
					_RimColor={0,0,0}
				},
				shadersettings={
					_Threshold=11
				},
				texture="board_internalOut.png"
			},
			body={
				--mesh="surferbot.obj",
				shader="RimLightHatchedSurferExternal", -- don't use the transparency shader in lofi mode. less fillrate needed that way
				renderqueue=3000,
				shadercolors={
					_Color={colorsource="highway", scaletype="intensity", minscaler=3, maxscaler=3},
					_RimColor={0,0,0}
				},
				shadersettings={
					_Threshold=1.7
				},
				texture="robot_HighContrast.png"
			}
		}
	}
else
	SetPlayer{
		--showsurfer = false,
		--showboard = false,
		cameramode = "third",
	--	cameramode_air = "first",--"first_jumptrickthird", --start in first, go to third for jumps and tricks

		camfirst={
			pos={0,1.84,-0.8},
			rot={20,0,0}},
		camthird={
			pos={0,2,-0.5},
			rot={30,0,0},
			strafefactorFar = 0.5,
			pos2={0,5,-5},
			rot2={30,0,0},
			transitionspeed = 5,
			puzzleoffset=-0.5,
			puzzleoffset2=-1.5},
		vehicle={ --livecoding not supported here
			min_hover_height= 0.0,
			max_hover_height = 0.0,
			use_water_rooster = false,
            smooth_tilting = false,
            smooth_tilting_speed = 0,
            smooth_tilting_max_offset = -0,
			pos={x=0,y=0,z=0},
			mesh="ninjamono.obj",
			--shader="VertexColorUnlitTintedPixelate",
			shader="VertexColorUnlitTinted",
			--layer = ifhifi(14,15), -- in hifif mode, render it to the topmost only. so the non-pixelated parts don't show through
			layer = 15,
			reflect = false,
			renderqueue = 2000,
			shadersettings={_Brightness=1.5},
			shadercolors = {_Color="highway"},
			texture="ninjamono.png",
			scale = {x=2,y=2,z=2}
		}
	}
end

--if hifi then
--	SetSkybox{
--		skyscreen = "Skyscreen/TheGrid"
--	}
--else
SetSkybox{
	color = {r=0.5, g=0.5, b=0.5},
	custom={
		_FrontTex = "Front.png",
		_BackTex = "Back.png",
		_LeftTex = "Left.png",
		_RightTex = "Right.png",
		_UpTex = "Top.png",
		_DownTex = "Bottom.png"
	}
}
--end

SetTrackColors{ --enter any number of colors here. The track will use the first ones on less intense sections and interpolate all the way to the last one on the most intense sections of the track
{r=206, g=120, b=92},--Copper
{r=255, g=255, b=0}, --Gold
{r=200, g=200, b=200},--Iron
{r=0, g=255, b=255},--Diamond
{r=0, g=255, b=0}--Emerald
}

if skinvars.colorcount < 5 then
	SetBlockColors{
	    {r=0, g=176, b=255},
	    {r=0, g=184, b=0},
	    {r=255, g=255, b=0},
		{r=255, g=0, b=0}
	}
else
	SetBlockColors{
	    {r=214, g=0, b=254},
	    {r=0, g=176, b=255},
	    {r=0, g=184, b=0},
	    {r=255, g=255, b=0},
		{r=255, g=0, b=0}
	}
end

if ispuzzle then
	CreateLight{
		type= "directional",
		railoffset = -1,
		range = 10,
		intensity = 1,
		transform = {
			position={0,2,0}, rotation={.4,346.2,0}
		},
		color={255,255,255}
	}
end

SetRings{ --setup the tracks tunnel rings. the airtexture is the tunnel used when you're up in a jump
	texture="portal.png",
	--texture="Classic_OnBlack",
	--shader="VertexColorUnlitTintedAddSmooth",
	shader = "VertexColorUnlitTintedAddDouble",
	layer = 13, -- on layer13, these objects won't be part of the glow effect
	size=fif(jumping, trackWidth*2, 10*(trackWidth/5)), --22
	offset = fif(jumping, {0,0,0}, {0,1,0}),
	percentringed=.2,--ifhifi(2,.01),-- .2,
	airtexture="Bits.png",
	airshader="VertexColorUnlitTintedAddSmoothNoDepth",
	airsize=16
}

--wakeHeight = 2
--if jumping then wakeHeight=2 else wakeHeight = 0 end
--SetWake{ --setup the spray coming from the two pulling "boats"
--	height = wakeHeight,
--	fallrate = 0.95,
--	shader = "VertexColorUnlitTinted",
--	layer = 13, -- looks better not rendered in background when water surface is not type 2
--	bottomcolor = {r=0,g=0,b=100},
--	topcolor = "highway"
--}

wakeHeight = 2
if jumping then wakeHeight=2 else wakeHeight = 0 end
SetWake{ --setup the spray coming from the two pulling "boats"
	height = wakeHeight,
	fallrate = .999,
	shader = "VertexColorUnlitTintedAddSmooth",
	layer = 13, -- looks better not rendered in background when water surface is not type 2
	bottomcolor = "highway",
	topcolor = {r=0,g=0,b=0}
}

if not jumping then
	CreateRail{--surface
		positionOffset={
			x=0,
			y=0},
		crossSectionShape={
			{x=-trackWidth,y=0},
			{x=trackWidth,y=0}},
		perShapeNodeColorScalers={
			1,
			1},
		--colorMode="static",
		colorMode="static",
		color = {r=0,g=0,b=0},
		renderqueue=3000,
		flatten=false,
		fullfuture=true,
		shader="VertexColorUnlitTinted"
		--hadersettings={_StartDistance=0, _FullDistance=15}
	}
	local laneDividers = skinvars["lanedividers"]
	for i=1,#laneDividers do
		CreateRail{ -- lane line
			positionOffset={
				x=laneDividers[i],
				y=0.1},
			crossSectionShape={
				{x=-.1,y=0},
				{x=.1,y=0}},
			perShapeNodeColorScalers={
				1,
				1},
			colorMode="highway",
			color = {r=255,g=255,b=255},
			flatten=false,
			fullfuture = true,
			shadersettings={_Brightness=1.42},
			shader="VertexColorUnlitTinted"
		}
	end
	CreateRail{--left Line
	positionOffset={
		x=-trackWidth,
		y=0},
	crossSectionShape={
		{x=0,y=0},
		{x=-0.25,y=0}},
		perShapeNodeColorScalers={
			1,
			1},
		--colorMode="static",
		colorMode="highway",
		color = {r=255,g=255,b=255},
		renderqueue=3000,
		flatten=false,
		fullfuture=true,
		--texture="cliffRails.png",
		shadersettings={_Brightness=1.42},
		shader="VertexColorUnlitTinted",
		--shadercolors = {_Color="highway"}
		--hadersettings={_StartDistance=0, _FullDistance=15}
	}
	CreateRail{--Right Line
	positionOffset={
		x=trackWidth,
		y=0},
	crossSectionShape={
		{x=0,y=0},
		{x=0.25,y=0}},
		perShapeNodeColorScalers={
			1,
			1},
		--colorMode="static",
		colorMode="highway",
		color = {r=255,g=255,b=255},
		renderqueue=3000,
		flatten=false,
		fullfuture=true,
		--texture="cliffRails.png",
		shadersettings={_Brightness=1.42},
		shader="VertexColorUnlitTinted",
		--shadercolors = {_Color="highway"}
		--shadersettings={_StartDistance=0, _FullDistance=15}
	}
end

CreateObject{
	name="EndingPortal",
	tracknode="end",
	gameobject={
		transform={pos={0,0,-2},scale={x=5*(trackWidth/5), y=5*(trackWidth/5), z=5*(trackWidth/5)},rot={0, 0, 0}},
		mesh="portal_start_track.obj",
		texture="portal_end_track.png",
		shader="VertexColorUnlitTinted",
		shadercolors = {_Color="highway"}
	}
}

CreateObject{
	name="StartPortal",
	tracknode="start",
	gameobject={
		transform={pos={0,0,2},scale={x=5*(trackWidth/5), y=5*(trackWidth/5), z=5*(trackWidth/5)},rot={180, 0, 0}},
		mesh="portal_end_track.obj",
		texture="portal_end_track.png",
		shader="VertexColorUnlitTinted",
		shadercolors = {_Color="highway"}
	}
}