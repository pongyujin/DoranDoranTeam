// store.js
import Vue from 'vue';
import Vuex from 'vuex';

Vue.use(Vuex);

export default new Vuex.Store({
    state: {
        waypoints: [] // 상태에 waypoints 추가
    },
    mutations: {
        setWaypoints(state, waypoints) {
            state.waypoints = waypoints;
        },
        setSailStatus(state, status) {
            state.sailStatus = status;
        }
    },
    actions: {
        saveWaypoints({ commit }, waypoints) {
            commit('setWaypoints', waypoints);
        },
        updateSailStatus({ commit }, status) {
            commit('setSailStatus', status);
        }
    }
});
