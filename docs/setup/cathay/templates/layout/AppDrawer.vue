<template>
  <q-drawer :model-value="modelValue" bordered show-if-above @update:model-value="$emit('update:modelValue', $event)">
    <q-scroll-area class="fit">
      <q-tree :nodes="navCollection" node-key="id" children-key="items" default-expand-all class="q-pa-sm">
        <template #default-header="{ node }">
          <!-- 有連結 -->
          <q-item v-if="node.url" clickable dense :to="node.url" class="full-width">
            <q-item-section v-if="node.icon" avatar>
              <span :class="node.icon" class="text-h6"></span>
            </q-item-section>

            <q-item-section>
              <q-item-label>
                {{ node.label }}
              </q-item-label>
            </q-item-section>
          </q-item>

          <!-- 群組節點 -->
          <div v-else class="row items-center no-wrap full-width q-gutter-sm">
            <span v-if="node.icon" :class="node.icon" class="text-h6"></span>

            <span class="text-weight-medium">
              {{ node.label }}
            </span>
          </div>
        </template>
      </q-tree>
    </q-scroll-area>
  </q-drawer>
</template>

<script setup>
  import navCollection from '@/service/NavCollection.js'

  defineProps(['modelValue'])
  defineEmits(['update:modelValue'])
</script>
