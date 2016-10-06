package  {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import amf.*;
	import data.*;
	
	
	
	public class dcp extends MovieClip {
		
		public var AMF:*;
		
		//---------
		// FB vars
		//---------
		public var fb_at:*;
		public var fb_uid:*;
		public var fb_sig:*;
		public var version:*;
		public var code:*;

		
		
		
		//-----------
		//	CP vars
		//-----------
		public var timer:Timer;
		public var sessionkey:*;
		public var char_id:*;
		public var stamina:*;
		//public var amfSeq = 0;
		public var enemy_clan_id:*;
		public var enemy_clan:*;
		public var enemyChar:*
		
		public function dcp() {
			addFrameScript(4, this.frame5);
			AMF = new amfConnect();
		}
		
		function amf(s:String,d:Array,f:Function):void{
			AMF.service(s,d,f);
		}
		
		function frame5():* {
			this.stop();
			
			//---------------
			//	Login Panel
			//---------------
			this["login_mc"].visible = true;
			this["login_mc"]["fb_at"].text = "";
			this["login_mc"]["fb_uid"].text = "";
			this["login_mc"]["fb_sig"].text = "";
			this["login_mc"]["char_id"].text = "";
			this["login_mc"]["version"].text = "3.3.00191";
			this["login_mc"]["spcode"].text = "907672";
			this["login_mc"]["submit_btn"].addEventListener(MouseEvent.CLICK, loadChar);
			//-------
			//	CP
			//-------
			this["rep_gain"].text = "0";
			this["char_name"].text = "-";
			this["stamina_txt"].text = "-";
			this["timer_txt"].text = "-";
			this["target"].text = "";
			this["msg"].text = "Made by Xwave";
			this["attack_btn"].addEventListener(MouseEvent.CLICK, attack);
		}
		function attack(e:MouseEvent=null):void {
			if ( this["target"].text == "" ) {
				this["msg"].text = "Input target clan first";
			}
			else {
				this.enemy_clan_id = this["target"].text;
				this.startAttack();
			}
			
		}
		
		function loadChar(e:MouseEvent=null):void {
			this.manual_load();
		}
		
		function manual_load():void {
			this.fb_at = this["login_mc"]["fb_at"].text;
			this.fb_uid = this["login_mc"]["fb_uid"].text;
			this.fb_sig = this["login_mc"]["fb_sig"].text;
			this.version = this["login_mc"]["version"].text;
			this.code =  this["login_mc"]["spcode"].text;
			
			
			if ( this["login_mc"]["fb_at"].text ==  "" || this["login_mc"]["fb_uid"].text == "" ||
				this["login_mc"]["fb_sig"].text == "") {
				
			}
			else {
				var codec:* = "85224034668";
				var req:* = "16849899572db5d92caf92.35187695";
				var loc1:* = req+String(this.fb_uid)+"facebook"+String(this.version)+codec;
				var loc2:* = (new clientLibrary).getLoginHash(req,loc1);
				amf("SystemService.snsLogin",[this.fb_uid,"facebook",this.version,req,loc2,this.fb_sig,this.fb_at,"en"], this.snsLoginResult);
			}
		}
		
		public var counter:int=0;
		function snsLoginResult(e:Object):void {
			if(e.error == 308) {
				AMF.setServer("https://app.ninjasaga.com/amf_live2/");
				if ( this.counter < 5 ){
					this.manual_load();
				}
				this.counter++;
			}
			else if (e.error == 102) {
				AMF.setServer("https://app.ninjasaga.com/amf_live2/");
				if ( this.counter < 5 ) {
					this.manual_load();
				}
				this.counter++;
			}
			else {
				this.sessionkey = e.result[3];
				this["login_mc"].visible = false;
				amf("CharacterDAO.getCharactersList", [this.sessionkey], this.getCharbyID);
			}
		}
		
		private function getCharbyID(e:Object):void
		{
			if(e.status == 0){
				this["msg"].text = "Error " + e.error;
			}
			else{
				if (this["login_mc"]["char_id"].text == "") {
					this["msg"].text = "Char id not specified, using 1st char...";
					this.char_id = e.result[0][0];
					amf("CharacterDAO.getCharacterById", [this.sessionkey, int(this.char_id)], this.loadClanz);
				}
				else {
					this.char_id = this["login_mc"]["char_id"].text;
					amf("CharacterDAO.getCharacterById", [this.sessionkey, int(this.char_id)], this.loadClanz);
				}
				
			}
		}
		
		function loadClanz(e:Object):void
		{
			this["char_name"].text = e.result.character_name;
			this.loadClanzz();
		}
		
		function loadClanzz():void
		{
			this["msg"].text = "ClanService.getClanStatus";
			amf("ClanService.getClanStatus", [this.sessionkey], this.getClanStatusResult);
		}
		
		function getClanStatusResult(e:Object):void
		{
			if( e.status != 1) {
				this["msg"].text = "Error " + e.error;
			}else {
				this["msg"].text = "ClanService.getClan";
				amf("ClanService.getClan", [this.sessionkey], this.getClanResult);
			}
		}
		
		function getClanResult(e:Object):void
		{
			if(e.status == 0){
				this["msg"].text = "Error " + e.error;
			}
			else if(e.result == 0){
				this["msg"].text = "Char don\'t have a clan";
			}
			else if(e.server_time > "1483142400"){
				this["msg"].text = "Expired";
			}
			else if (e.result == 1){
				if(e.clan_data.id == "100196"){
					this.stamina = e.clan_data.character_stamina;
					this["stamina_txt"].text = this.stamina;
					//mc["m_"+String(this.rank)]["char_clan_name"].text = e.clan_data.name;
					//mc["m_"+String(this.rank)]["char_stamina_rolls"].text = e.stamina_item;
					this.fileCheck();
				}else{
					this["msg"].text = "Error " + e.error;
				}
			}
			else {}
		}
		
		function fileCheck():void
		{
			var loc1:* = String(this.version);
			var fileCheckArray:* = new Array([(("https://ns-static-bwhcb6a5289.netdna-ssl.com/swf/" + loc1) + "/swf/panels/clan_panel.swf"), int(this.code),int(this.code), Boolean(true), int(10), int(3), Object]);
			var loc2:* = (new clientLibrary).getHash(this.sessionkey, "" + fileCheckArray[0][0]);
			amf("FileChecking.checkHackActivity", [this.sessionkey, fileCheckArray, loc2], this.fileCheckResult1);
		}
		
		function fileCheckResult1(e:Object):void{
			if(e.status == 0){
				this["msg"].text = "Error " + e.error;
			}else{
				this["msg"].text = "File check completed";
				if (this.enemy_clan_id != null ) {
					this.startAttack();
				}
			}
		}
		var amfSeq = 0;
		
		function updateSequence():String{
			this.amfSeq++;
			var hash:* = (new clientLibrary).getHash(this.sessionkey, String(this.amfSeq) );
			return hash;
		}
		
		
		function startAttack():void{
			if(this.stamina >= 10){
				amf("ClanService.getWarList", [this.sessionkey], this.searchClan);
			}
			else{
				this.waitStamina();
			}
		}
		
		function waitStamina():void {
			this["msg"].text = "No stamina left..Waiting for next restore..";
			this.timer = new Timer(1000,300);
			this.timer.addEventListener(TimerEvent.TIMER, this.timerRun);
			this.timer.addEventListener(TimerEvent.TIMER_COMPLETE, this.checkStam);
			this.timer.start();
			this["timer_txt"].text = int("300");
		}
		
		function timerRun(e:TimerEvent):void {
			var sec:* = this["timer_txt"].text;
			var left:*=sec-1;
			this["timer_txt"].text = String(left);
		}
		
		function checkStam(e:TimerEvent){ this.loadClanzz(); }
		
		function searchClan(e:Object):void{
			this.stamina = e.character_stamina;
			this["stamina_txt"].text = String(this.stamina);
			var loc1:* = this.enemy_clan_id;
			var loc2:* = (new clientLibrary).getHash(this.sessionkey, loc1);
			this["msg"].text = "ClanWar.searchClan";
			amf("ClanWar.searchClan", [this.sessionkey,loc2,loc1], this.getMemberList);
		}
		
		function getMemberList(e:Object):void{
			if (e.status != 1) {
				this["msg"].text = "Error " + e.error;
			}else{
				this.enemy_clan = new Array(e.war_list[0]);
				this["msg"].text = "ClanWar.getMemberList";
				amf("ClanWar.getMemberList", [this.sessionkey], this.getBattleDefender);
			}
		}
		
		function getBattleDefender(e:Object):void{
			if (e.status != 1) {
				this["msg"].text = "Error " + e.error;
			}else{
				this.stamina = String(int(this.stamina) - int(10));
				this["stamina_txt"].text = String(this.stamina);
				var loc1:* = String(this.enemy_clan[0].id) + "" + this.sessionkey;
         		var loc2:* = (new clientLibrary).getHash(this.sessionkey, loc1+String(this.code)); //loc1+swfsize
				this["msg"].text = "ClanWar.getBattleDefender";
				amf("ClanWar.getBattleDefender", [this.sessionkey, this.updateSequence(), loc2, int(this.enemy_clan[0].id), String(this.enemy_clan[0].name), "", false], this.Defender01);
			}
		}
		
		function Defender01(e:Object):void{
			//remove shit if its not working
			if ( e.error == 292 ) {
				this["msg"].text = "Error " + e.error;
			}
			if(e.error == 307){
				this["msg"].text = "Error " + e.error;
			}
			if(e.error == 100){
				this["msg"].text = "Error " + e.error;
			}
			if(e.result == 2){
				if(e.battle_result == 1){
					this["msg"].text = "Enemy is bleeding";
					this["rep_gain"].text = String(int(e.rep_gain) + int(this["rep_gain"].text));
					this.startQtimer();
				}
				if(e.battle_result == 2){
					this["msg"].text = "Enemy is not bleeding";
					this["rep_gain"].text = String(int (e.rep_gain) + int (this["rep_gain"].text));
					this.startQtimer();
				}
			}
			this.enemyChar = new Array(e.defenders[0],e.defenders[1],e.defenders[2]);
			amf("CharacterDAO.getCharacterProfileById", [this.sessionkey, Number(this.enemyChar[0])], this.Defender02);
		}
		
		function startQtimer():void{
			this.timer = new Timer(1000,4);
			this.timer.addEventListener(TimerEvent.TIMER_COMPLETE, endQtimer);
			this.timer.start();
		}
		
		function endQtimer(e:TimerEvent):void{
			this.startAttack();
		}
		
		function Defender02(arg1:Object):void{
            amf("CharacterDAO.getCharacterProfileById", [this.sessionkey, Number(this.enemyChar[1])], this.Defender03);
        }

        function Defender03(arg1:Object):void{
            amf("CharacterDAO.getCharacterProfileById", [this.sessionkey, Number(this.enemyChar[2])], this.ManualTimer);
        }
		
		function ManualTimer(e:Object):void{
			this["msg"].text = "Waiting for delay..";
			this.timer = new Timer(1000,70);
			this.timer.addEventListener(TimerEvent.TIMER, this.timerRun);
			this.timer.addEventListener(TimerEvent.TIMER_COMPLETE, generateBattleResult);
			this.timer.start();
			this["timer_txt"].text = int("70");
		}
		
		function generateBattleResult(e:TimerEvent):void{
            var sig:* = (new clientLibrary).getHash(this.sessionkey, String("1") + "" + this.sessionkey);
			amf("ClanWar.generateBattleResult",[this.sessionkey, this.updateSequence(), String("1"), "", sig], flushBattleStat);
		}
		
		function flushBattleStat(e:Object):void{
			if (e.status != 1) {
				this["msg"].text = "Error " + e.error;
			}else{
				this["msg"].text = String("You got ") + String(e.rep_gain) + String(" rep");
				this["rep_gain"].text = String(int (e.rep_gain) + int (this["rep_gain"].text));
				var battleStat:* = {1:1, 2:6, 3:36, 4:69, 5:0, 7:3, 8:0, 9:0, 10:0, 11:0};
				var battleStatArr:* = new Array();
				for(var i in battleStat){
					battleStatArr.push(battleStat[i]);
				}
				var loc1:* = (new clientLibrary).getHash(this.sessionkey, "Achievement.flushBattleStat" + battleStatArr.toString() );
				amf("Achievement.flushBattleStat", [this.sessionkey, this.updateSequence(), loc1, battleStat], flushBattleStatdone);
			}
		}
		
		function flushBattleStatdone(e:Object):void{
			if(e.error == 100){
				//this.compute(this.fb_uid,this.fb_sig,this.fb_at,this.enemy_clan_id);
				this["msg"].text = "Error " + e.error;
			}
			else{
				this.timer = new Timer(1000,5);
				this.timer.addEventListener(TimerEvent.TIMER_COMPLETE, this.tmrComplete);
				this.timer.start();
			}
		}
		
		function tmrComplete(e:TimerEvent):void{this.startAttack();}
		
		
		
		
		
		
		
		
	}
	
}
