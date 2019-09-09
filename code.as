//###########################
// Stackopolis Game Engine
// by Vish Vishvanath - vish@blocmedia.com
// ©2002 blocmedia
// Version 1.0
// November 14 2002
//###########################




Movieclip.prototype.fade = function(ratio, friction, alpha)
{
	if (this._alpha != alpha)
	{
		this.ratio = "." + ratio;
		this.friction = "." + friction;
		this.alpha = alpha;
		this.speedX = ((this.alpha - this._alpha) * this.ratio) + (this.speedX * this.friction);
		this._alpha += this.speedX;
	}
};
//
//###########################
//
function Stack(playerName)
{
	this.playername = playerName;
	// use for score later!
	this.intervalID = undefined;
	this.tileWidth = 96;
	this.tileHeight = 48;
	this.alpha = 100;
	this.run = false;
	this.createSounds();
	this.main();
}
//
//###########################
//
// Internal functions
//
//###########################
//
Stack.prototype.createSounds = function()
{
	this.tick = new Sound();
	this.choose = new Sound();
	this.change = new Sound();
	this.winsound = new Sound();
	this.tick.attachSound("tick");
	this.choose.attachSound("choose");
	this.change.attachSound("change");
	this.winsound.attachSound("win");
}
//
//###########################
//
Stack.prototype.main = function()
{
	this.getMaps();
	this.mode = "choose";
	this.level = 0;
	this.moves = 0;
	this.timer = 60;
	this.currentTime = 60;
	_root.levels.gotoAndStop(1);
};
//
//###########################
//
Stack.prototype.win = function()
{
	this.show("welldone");
	this.winsound.start(0,0);
	this.end();
	this.displayRender();
	//trace("YOU WIN!");
};
Stack.prototype.lose = function()
{
	this.main();
	this.end();
	this.show("gameover");
	_root.gameover.gotoAndPlay(2);
};
//
//###########################
//
Stack.prototype.showNext = function()
{
	_root.nextLevel._visible = true;
};
Stack.prototype.hideNext = function()
{
	_root.nextLevel._visible = false;
};
//
//###########################
//
Stack.prototype.displayRender = function()
{
	var tmp_name = "render" + this.level;
	_root.renders.gotoAndPlay(tmp_name);
	trace("display render " + tmp_name);
};
//
//###########################
//
Stack.prototype.toggleMode = function()
{
	//trace("toggle mode");
	if (this.mode == "choose")
	{
		this.choose.start(0,0);
		this.mode = "change";
	}
	else if (this.mode == "change")
	{
	this.change.start(0,0);
		this.mode = "choose";
	}
};
//
//###########################
//
Stack.prototype.pushBlock = function(name)
{
	if (this.checkActive())
	{
		var tmp_name = name;
		var location = tmp_name.split(",", 2);
		var tmp_i = location[0];
		var tmp_j = location[1];
		var num = this.currentMap[tmp_i][tmp_j];
		//trace("pushBlock - " + this.mode + " Number " + num + " >> i: " + location[0] + ", " + location[1]);
		if (this.mode == "choose")
		{
			if (number == 0)
			{
				break;
				// Fuck off out of this loop - you clicked on an empty square, you loser
			}
			else
			{
				this.toggleMode();
				this.currentMap[tmp_i][tmp_j] = num - 1;
				//change the current map to reflect the screen
				_root.container[name].prevFrame();
				// change the block on screen
			}
		}
		else if (this.mode == "change" && num != 9)
		{
			this.currentMap[tmp_i][tmp_j] = num + 1;
			_root.container[name].nextFrame();
			this.moves++;
			this.toggleMode();
			if (this.currentMap.toString() == this.currentWinMap.toString())
			{
				this.win();
			}
			else
			{
				//trace("no win");
				break;
				// you don't win, you loser
			}
		}
		//trace("Current Map: " + this.currentMap.toString());
		//trace("Winning Map: " + this.currentWinMap.toString());
	}
};
//
//###########################
//
Stack.prototype.removeBlocks = function()
{
	//trace("remove blocks");
	_root.container.removeMovieClip();
	return true;
};
//
//###########################
//
Stack.prototype.resetScreen = function()
{
	//trace("reset screen");
	if (this.removeBlocks())
	{
		_root.createEmptyMovieClip("container", 100);
		_root.container._x = 351;
		_root.container._y = 327;
		_root.container.onEnterFrame = function()
		{
			_root.container.fade(4, 1, game.alpha);
		};
	}
};
//
//###########################
//
Stack.prototype.nextLevel = function()
{
	this.hide("welldone");
	this.hide("nextLevel");
	var maxLevels = this.map.length;
	//trace(maxLevels);
	if (this.level < (maxLevels-1))
	{
		this.level++;
	}
	else
	{
		this.level = 0;
	}
	trace("next Level " + this.level);
	_root.countdown.gotoAndPlay(2);
	_root.renders.gotoAndStop("empty");
	_root.levels.nextFrame();
};
//
//###########################
//
Stack.prototype.buildMap = function()
{
	trace("build Map " + this.level);
	this.toggle = "choose";
	this.getMaps();
	this.currentMap = this.map[this.level];
	this.currentWinMap = this.winmap[this.level];
	var mapWidth = this.currentMap[0].length;
	var mapHeight = this.currentMap.length;
	//	trace("width: " + mapWidth + " height: " + mapHeight);
	for (var i = 0; i < mapHeight; ++i)
	{
		for (var j = 0; j < mapHeight; ++j)
		{
			var tmp_name = i + "," + j;
			_root.container.attachMovie("tile", tmp_name, ++d);
			_root.container[tmp_name]._x = (this.tileWidth / 2) * (j - i);
			_root.container[tmp_name]._y = (this.tileHeight / 2) * (j + i);
			_root.container[tmp_name].gotoAndStop(this.currentMap[i][j] + 1);
		}
	}
};
// ####
//
//###########################
//
Stack.prototype.begin = function()
{
	trace("begin");
	this.resetScreen();
	this.buildMap();
	this.run = true;
	this.alpha = 100;
	this.resetTimer();
	this.startTimer();
};
//
Stack.prototype.end = function()
{
	trace("end");
	this.run = false;
	this.alpha = 0;
	this.stopTimer();
};
//
//###########################
//
Stack.prototype.checkActive = function()
{
	if (this.run == true)
	{
		return true;
	}
	else
	{
		return false;
	}
};
//
//###########################
//
Stack.prototype.getMaps = function()
{
	trace ("getting maps!");
	// ################
	// Map data
	this.mastermap = new Array();
	this.map = new Array();
	this.winmap = new Array();
	//
	this.mastermap[0] = [[0, 3, 0, 2, 4, 0], [0, 1, 5, 0, 0, 0], [0, 2, 3, 4, 0, 1], [0, 0, 2, 0, 3, 0], [0, 3, 0, 0, 2, 0], [0, 2, 0, 0, 4, 0], [0, 0, 4, 0, 1, 0]];
	this.mastermap[1] = [[0, 9, 0, 1, 0, 0], [0, 1, 0, 9, 0, 0], [0, 5, 0, 5, 0, 0], [0, 5, 0, 5, 0, 0], [0, 5, 0, 5, 0, 0], [0, 9, 0, 1, 0, 0], [0, 1, 0, 9, 0, 0]];
	this.mastermap[2] = [[1, 1, 1, 3, 0, 9], [0, 5, 5, 0, 0, 0], [0, 1, 0, 5, 0, 0], [0, 0, 1, 2, 0, 0], [0, 0, 0, 1, 3, 0], [0, 0, 1, 0, 9, 5], [0, 0, 0, 0, 0, 9]];
	//
	this.winmap[0] = [[0, 0, 0, 0, 0, 0], [0, 2, 2, 2, 2, 0], [0, 2, 3, 3, 2, 0], [0, 2, 3, 3, 2, 0], [0, 2, 3, 3, 2, 0], [0, 2, 2, 2, 2, 0], [0, 0, 0, 0, 0, 0]];
	this.winmap[1] = [[0, 0, 0, 0, 0, 0], [2, 2, 2, 2, 2, 0], [2, 4, 4, 4, 2, 0], [2, 4, 6, 4, 2, 0], [2, 4, 4, 4, 2, 0], [2, 2, 2, 2, 2, 0], [0, 0, 0, 0, 0, 0]];
	this.winmap[2] = [[0, 0, 0, 0, 0, 3], [0, 0, 0, 0, 3, 3], [0, 0, 0, 3, 3, 2], [0, 0, 0, 3, 2, 2], [0, 3, 3, 3, 2, 2], [0, 3, 2, 2, 2, 2], [3, 3, 2, 2, 2, 2]];
	//
	this.map[0] = this.mastermap[0];
	this.map[1] = this.mastermap[1];
	this.map[2] = this.mastermap[2];
};
//
//###########################
// Timer functions
//###########################
//
Stack.prototype.resetTimer = function()
{
	trace("reset timer");
	this.currentTime = this.timer;
	this.displayTimer();
};
Stack.prototype.reduceTimer = function()
{
	trace("reduce timer " + game.currentTime);
	game.currentTime--;
	game.tick.start(0,0);
	if (game.currentTime == 0)
	{
		trace("you lose!");
		game.stopTimer();
		game.lose();
	}
	game.displayTimer();
};
Stack.prototype.displayTimer = function()
{
	trace("display timer");
	_root.timer = this.currentTime;
};
Stack.prototype.startTimer = function()
{
	trace("start timer");
	this.intervalID = setInterval(this.reduceTimer, 1000);
	trace("interval ID set: " + this.intervalID);
};
Stack.prototype.stopTimer = function()
{
	trace("stop timer: " + this.intervalID);
	clearInterval(this.intervalID);
};
//
//###########################
//
Stack.prototype.show = function(clipname)
{
	_root[clipname]._visible = true;
}

Stack.prototype.hide = function(clipname)
{
	_root[clipname]._visible = false;
}
//
//###########################
//
_global.game = new Stack();
//_root.countdown.gotoAndPlay(2);
