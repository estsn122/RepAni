<template>
  <div>
    <v-container>
      <v-row id="terms_list">
        <v-card
          v-for="term in sortedTerms"
          :id="'term_' + term.id"
          :key="term.id"
          class="rounded-lg mt-3 mx-auto"
          outlined
          :color="term.id == selectTerm.id ? 'indigo lighten-4' : ''"
          @click="handleSelectTerm(term)"
        >
          <v-list-item>
            <v-list-item-content>
              <v-list-item-title class="headline mb-1">
                {{ term.year }}年{{ term.season_ja }}アニメ
              </v-list-item-title>
            </v-list-item-content>
            <v-card-actions />
          </v-list-item>
        </v-card>
      </v-row>
    </v-container>
  </div>
</template>

<script>
export default {
  name: "TermList",
  props: {
    // selectTermを親から受け取ってるのは、初期表示時に対応するため
    selectTerm: {
      type: Object,
      required: true
    },
    terms: {
      type: Array,
      required: true
    },
  },
  computed: {
    sortedTerms () {
      const orderRule = ['winter', 'spring', 'summer', 'autumn']
      return this.terms.slice().sort(function(a,b){
        if(a.year < b.year) return 1;
        if(a.year > b.year) return -1;
        if(orderRule.indexOf(a.season) < orderRule.indexOf(b.season)) return 1;
        if(orderRule.indexOf(a.season) > orderRule.indexOf(b.season)) return -1;
        return 0;
      });
    },
  },
  methods: {
    handleSelectTerm(term) {
      this.$emit('select-term', term)
    }
  },
}
</script>
