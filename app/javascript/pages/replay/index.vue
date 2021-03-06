<template>
  <div>
    <v-container>
      <v-row>
        <v-col
          v-if="selectEpisode"
          cols="6"
        >
          <v-breadcrumbs :items="items">
            <template v-slot:item="{ item }">
              <v-breadcrumbs-item
                :to="item.to"
              >
                {{ item.text.toUpperCase() }}
              </v-breadcrumbs-item>
            </template>
          </v-breadcrumbs>
          <v-col offset="1">
            <h2>{{ selectAnime.title }}</h2>
            <h2>
              {{ selectEpisode.num }}話
              <span v-if="selectEpisode.subtitle">
                『{{ selectEpisode.subtitle }}』
              </span>
            </h2>
            <Timer
              id="timer"
              ref="timer"
              :episode="selectEpisode"
            />
            <AnimeInfo
              id="anime_info"
              :anime="selectAnime"
              :episode="selectEpisode"
            />
            <v-btn
              id="toOtherEpisode"
              small
              color="success"
              @click="handleShowEpisodesDialog"
            >
              別の話へ
            </v-btn>
          </v-col>
        </v-col>
        <v-col
          cols="5"
          class="mb-5"
        >
          <div
            v-for="tweet in showTweets"
            :key="tweet.id"
            class="my-5"
          >
            <Tweet :tweet="tweet" />
          </div>
        </v-col>
        <EpisodesDialog
          ref="dialog"
          :anime="selectAnime"
          :episodes="episodes"
        />
      </v-row>
    </v-container>
  </div>
</template>

<script>
import Timer from './components/Timer'
import Tweet from './components/Tweet'
import AnimeInfo from './components/AnimeInfo'
import EpisodesDialog from './components/EpisodesDialog'
const CHECK_INTERVAL_TIME_MSEC = 300
const CUT_SHOW_TWEETS_NUM = 30
const CHECK_STACK_TWEETS_NUM = 100

export default {
  name: "ReplayIndex",
  components: {
    Timer,
    Tweet,
    AnimeInfo,
    EpisodesDialog,
  },
  data() {
    return {
      episodeId: this.$route.params.episodeId,
      //selectEpisodeの初期値を{}とすると、Timer.vueにセットされた値が渡るタイミングが遅く、エラーとなる
      selectEpisode: "",
      episodes: [],
      selectAnime: {},
      stackTweets: [],
      showTweets: [],
      lastTweetExists: false,
      prevBarMsec: 0,
      isFetchTweets: false,
      items: [
        {
          text: 'トップ',
          to: '/',
        },
        {
          text: '放送時期',
          to: '/anime',
        },
        {
          text: 'アニメ',
          to: '',
        },
      ]
    }
  },
  watch: {
    $route (to, from) {
      this.init()
    }
  },
  created() {
    this.init()
  },
  methods: {
    async init(){
      await this.fetchAnimeAndEpisode()
      this.$watch(
        function () {
          //return this.$refs.timer.$data.barMsec
          return this.$refs.timer.$data.value
        },
        function() {
          if(this.$refs.timer.$data.timerOn && (this.$refs.timer.$data.barMsec - this.prevBarMsec) > CHECK_INTERVAL_TIME_MSEC) {
            this.stackToShowTweets()
            this.prevBarMsec = this.$refs.timer.$data.barMsec
            this.removeSomeShowTweets()
            // 既に削除された画像のリンクにアクセスした際、エラーログが表示されて大量のログがブラウザに残るため
            console.clear()
          }
        }
      )
      this.$watch(
        function () {
          return this.$refs.timer.$data.timerOn
        },
        function() {
          if (this.$refs.timer.$data.timerOn) {
            // タイマーが始まったらshowTweetsを空にする
            this.showTweets = []
            this.prevBarMsec = this.$refs.timer.$data.barMsec
          } else {
            // タイマーが止まったらstackTweetsを空にする
            this.stackTweets = []
            this.lastTweetExists = false
          }
        }
      )
      this.$watch(
        function () {
          return (this.$refs.timer.$data.timerOn) &&
                 (this.stackTweets.length < CHECK_STACK_TWEETS_NUM) &&
                 (!this.lastTweetExists)
        },
        function() {
          this.fetchTweets()
        }
      )
    },
    async fetchAnimeAndEpisode() {
      await this.$axios.get("episodes/info", {params: {episode_id: this.$route.params.episodeId }})
        .then(res => {
          this.selectAnime = res.data.anime
          this.selectEpisode = res.data.episode
        })
        .catch(err => console.log(err.status));
    },
    async fetchTweets() {
      if (this.isFetchTweets) return

      this.isFetchTweets = true

      // 実際の実装では=とせずstackTweetsに追加するようにする
      //TODO: パラメーターのprogressを取りたい
      let tweet_id = ""
      if(this.stackTweets.length) {
        let lastTweet = this.stackTweets[this.stackTweets.length - 1]
        tweet_id = lastTweet.tweet_id
      }
      await this.$axios.get("tweets", {params: {episode_id: this.selectEpisode.id, tweet_id: tweet_id, progress_time_msec: this.$refs.timer.$data.barMsec}})
        .then(res => {
          this.stackTweets.push(...res.data.tweets)
          this.lastTweetExists = res.data.last_tweet_exists
          res = null
        })
        .catch(err => console.log(err.status));

      this.isFetchTweets = false
    },
    stackToShowTweets(){
      if (this.stackTweets.length == 0) return

      while (this.stackTweets[0].progress_time_msec <= this.$refs.timer.$data.barMsec) {
        if (this.showTweets.includes(this.stackTweets[0])) {
          this.stackTweets.shift()
          continue
        }
        this.showTweets.unshift(this.stackTweets.shift());
      }
    },
    async handleShowEpisodesDialog() {
      await this.$axios.get("episodes", { params: this.selectAnime })
        .then(res => this.episodes = res.data)
        .catch(err => console.log(err.status));
      this.$refs.dialog.open();
    },
    removeSomeShowTweets(){
      while(this.showTweets.length > CUT_SHOW_TWEETS_NUM) {
        this.showTweets.splice((this.showTweets.length - 10), 10)
      }
    },
  },
}
</script>
<style scoped>
#timer {
  margin-top: 40px;
}
#anime_info {
  margin-top: 40px;
}
#toOtherEpisode {
  margin-left: 100px;
}
</style>
