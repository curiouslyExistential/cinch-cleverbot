require 'cinch'
require 'set'
require 'cleverbot'
require 'active_support'

class CleverBot
  include Cinch::Plugin

  match lambda { |m| /^#{m.bot.nick}: (.+)/i }, use_prefix: false
  match "disablechatter", use_prefix: true, method: :disableChanChat
  match "enablechatter", use_prefix: true, method: :enableChanChat
  match "globaldisable", use_prefix: true, method: :globalDisable
  match "globalenable", use_prefix: true, method: :globalEnable
  match "chatterhelp", use_prefix: true, method: :chatterHelp

  def initialize(*args)
    super
    @admins = []
    @enabled = true
    @prefixUse = true
    @disabledChannels = Set.new []
    @cleverbot = Cleverbot::Client.new
  end

  def execute(m, message)
  return unless @enabled
    if @disabledChannels.include?(m.channel)
      return
    else
      msg_back = @cleverbot.write message
      m.reply(msg_back, @prefixUse)
    end
  end
	  
  def chatterHelp(m)
    m.reply("Available commands for privileged users (voice and up): ~disablechatter, ~enablechatter", @prefixUse)
  end
	  
  def disableChanChat(m, channel)
    if m.channel.opped?(m.user) or m.channel.half_opped?(m.user) or m.channel.voiced?(m.user)
      if @disabledChannels.add?(m.channel) == nil
        m.reply(m.channel " already has CleverBot disabled.", @prefixUse)
        return
      else
        m.reply(m.channel " now has CleverBot disabled.", @prefixUse)
        return
      end
    end
  end

  def enableChanChat(m, channel)
    if m.channel.opped?(m.user) or m.channel.half_opped?(m.user) or m.channel.voiced?(m.user)
      if @disabledChannels.add?(m.channel) == nil
        m.reply(m.channel " already has CleverBot enabled.", @prefixUse)
        return
      else
        m.reply(m.channel " now has CleverBot enabled.", @prefixUse)
        return
      end
    end
  end
	  
  def globalDisable()
    return unless check_user(m.user)
    if @enabled == true
      @enabled = false
      m.reply("CleverBot is now globally disabled.", @prefixUse)
    else
      m.reply("CleverBot is already globally disabled.", @prefixUse)
    end
  end

  def globalEnable()
    return unless check_user(m.user)
    if @enabled == false
      @enabled = true
      m.reply("CleverBot is now globally enabled.", @prefixUse)
    else
      m.reply("CleverBot is already globally enabled.", @prefixUse)
    end
  end

  def check_user(user)
    user.refresh # be sure to refresh the data, or someone could steal
                 # the nick
    @admins.include?(user.authname)
  end
end