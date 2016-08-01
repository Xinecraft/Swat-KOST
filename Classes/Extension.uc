class Extension extends Julia.Extension implements Julia.InterestedInInternalEventBroadcast,HTTP.ClientOwner;

import enum eClientError from HTTP.Client;

/**
 * HTTP client instance
 * @type class'HTTP.Client'
 */
var protected HTTP.Client Client;

/**
 * KOST service URL
 * @type string
 */
var config string URL;

/**
 * Server Query KEY
 * @type string
 */
var config string Key;

var config string ServerUID;

var config bool Compatible;

/**
 * @return  void
 */
public function PreBeginPlay()
{
    Super.PreBeginPlay();

    if (Level.NetMode == NM_ListenServer || Level.NetMode == NM_DedicatedServer)
    {
        if (Level.Game != None && SwatGameInfo(Level.Game) != None)
        {
            if (self.URL != "" || self.Key != "")
            {
                return;
            }
        }
    }
    self.Destroy();
}

public function BeginPlay()
{
    Super.BeginPlay();
    log("Kinnngg's Online Stats Tracker (KOST) initialised!");
    //self.Core.RegisterInterestedInPlayerPawnChanged(self);
    self.Core.RegisterInterestedInInternalEventBroadcast(self);
    self.Client = Spawn(class'HTTP.Client');
}

public function OnInternalEventBroadcast(name Type, optional string Msg, optional Player PlayerOne, optional Player PlayerTwo)
{
    switch (Type)
    {
        case 'PlayerSuicide':
            self.SendRequest(Type, PlayerOne, PlayerTwo, Msg);
            break;
        case 'PlayerArrest':
            self.SendRequest(Type, PlayerOne, PlayerTwo, Msg);
            break;
        case 'PlayerTeamKill':
            self.SendRequest(Type, PlayerOne, PlayerTwo, Msg);
            break;
        case 'PlayerKill':
            self.SendRequest(Type, PlayerOne, PlayerTwo, Msg);
            break;
        case 'PlayerTeamHit':
            if(InStr(Caps(Msg),"TASER") >= 0)
            {
                self.SendRequest(Type, PlayerOne, PlayerTwo, Msg);
            }
            break;
        case 'PlayerHit':
            if(InStr(Caps(Msg),"TASER") >= 0)
            {
                self.SendRequest(Type, PlayerOne, PlayerTwo, Msg);
            }
            break;
        default:
            break;
    }
}

/**
 * Parse a successful HTTP request in order to respond to a dispatched player command (whois)
 *
 * @see HTTP.ClientOwner.OnRequestSuccess
 */
public function OnRequestSuccess(int StatusCode, string Response, string Hostname, int Port)
{
    local array<string> Lines;
    local Player PlayerOne,PlayerTwo;

    log(Hostname $ ":" $ Port $ " returned " $ StatusCode);
    log("Response:"$ Response);
    if (StatusCode == 200)
    {
        Lines = class'Utils.StringUtils'.static.Part(Response, "\n");
        switch (Lines[0])
        {
            case "PlayerSuicide":
                PlayerOne = self.Core.GetServer().GetPlayerByWildName(Lines[1]);
                //class'Utils.LevelUtils'.static.TellPlayer(self.Level, PlayerOne.GetLastName() , "808080");
                class'Utils.LevelUtils'.static.TellPlayer(self.Level, Lines[2], PlayerOne.GetPC(), "808080");
                break;

            case "PlayerArrest":
            case "PlayerTeamKill":
            case "PlayerKill":
            case "PlayerTeamHit":
            case "PlayerHit":
                PlayerOne = self.Core.GetServer().GetPlayerByWildName(Lines[1]);
                PlayerTwo = self.Core.GetServer().GetPlayerByWildName(Lines[2]);
                //class'Utils.LevelUtils'.static.TellAll(self.Level, PlayerOne.GetLastName()$" - "$PlayerTwo.GetLastName() , "F0F0F0");
                class'Utils.LevelUtils'.static.TellPlayer(self.Level, Lines[3], PlayerOne.GetPC(), "808080");
                class'Utils.LevelUtils'.static.TellPlayer(self.Level, Lines[4], PlayerTwo.GetPC(), "808080");
                //class'Utils.LevelUtils'.static.TellAll(self.Level, Lines[3] , "808080");
                //class'Utils.LevelUtils'.static.TellAll(self.Level, Lines[4] , "808080");
                break;

            default:
                break;
        }
        /**for (i = 0; i<Lines.Length; i++)
        {
            class'Utils.LevelUtils'.static.TellAll(self.Level, Lines[i] , "FFFFFF");
        }*/
        return;
    }
    log(self $ " received invalid response from " $ Hostname $ " (" $ StatusCode $ ":" $ Left(Response, 20) $ ")");
}

/**
 * @see HTTP.ClientOwner.OnRequestFailure
 */
public function OnRequestFailure(eClientError ErrorCode, string ErrorMessage, string Hostname, int Port)
{
    log(Hostname $ ":" $ Port $ " failed with code " $ GetEnum(eClientError, ErrorCode) $ " - " $ ErrorMessage);
}

function SendRequest(name Type, Player PlayerOne, optional Player PlayerTwo, optional string Msg)
{
  local HTTP.Message Request;
  local int Port;

  Port = SwatGameInfo(Level.Game).GetServerPort();

  Request = Spawn(class'HTTP.Message');

  // Fill a form
  self.AddRequestItem(Request, self.ServerUID, "", "server_uid");
  self.AddRequestItem(Request, self.Key, "", "key");
  self.AddRequestItem(Request, Port, "", "server_port");
  self.AddRequestItem(Request, Type, "", "type");
  self.AddRequestItem(Request, PlayerOne.GetLastName(), "", "playerone");
  self.AddRequestItem(Request, PlayerOne.GetIPAddr(), "", "playeroneip");
  self.AddRequestItem(Request, PlayerTwo.GetLastName(), "", "playertwo");
  self.AddRequestItem(Request, PlayerTwo.GetIPAddr(), "", "playertwoip");
  self.AddRequestItem(Request, Msg, "", "extra");
  // Use a cookie
  Request.AddHeader("Connection", "close");
  // Send a POST request
  // The request object will be automatically disposed
  self.Client.Send(Request, self.URL, 'POST', self, 1);
}


protected function AddRequestItem(
    HTTP.Message Request, coerce string Value, coerce string DefaultValue,
    coerce string Key1,
    coerce optional string Key2,
    coerce optional string Key3,
    coerce optional string Key4,
    coerce optional string Key5
)
{
    local string Key;
    // Skip items equal to the default value or items with empty value
    if (Value == "" || (DefaultValue != "" && Value == DefaultValue))
    {
        return;
    }
    // Construct a key in the form of foo[bar][ham]
    if (self.Compatible)
    {
        Key = class'Utils'.static.FormatArrayKey(Key1, Key2, Key3, Key4, Key5);
    }
    // Or use the efficient notation foo.bar.ham
    else
    {
        Key = class'Utils'.static.FormatDelimitedKey(Key1, Key2, Key3, Key4, Key5);
    }
    Request.AddQueryString(Key, Value);
}




event Destroyed()
{
    if(self.Client != None)
    {
      self.Client.Destroy();
    }
    if(self.Core != None)
    {
        self.Core.UnRegisterInterestedInInternalEventBroadcast(self);
    }
    Super.Destroyed();
}

defaultproperties
{
    Title="Kinnngg/KOST";
    Version="1.0.0";
    Compatible=True;
    //LocaleClass=class'Locale';
}
