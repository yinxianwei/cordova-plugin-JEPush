JEPush = {

    
    /*!
     *  指定推送模式和appkey
     *
     *  @param key  百度推送appkey
     *  @param mode 模式："0"：开发模式，"1"：生产模式
     *
     */
    apiKeyAndMode: function(key,mode){
        return Cordova.exec(null, null, "apiKeyAndMode", "apiKeyAndMode", [key,mode])
    },
    
    /**
     *  获取百度channel id，获取之前必须指定appkey和推送模式
     *
     *  @param result channelid:String
     *  @param fail   用户不允许
     *
     */
    getBChannelID: function(result, fail) {
        return Cordova.exec(result, fail, "getBChannelID", "getBChannelID", []);
    },
    
  
}
module.exports = JEPush;