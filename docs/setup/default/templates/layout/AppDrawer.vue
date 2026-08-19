<template>
  <q-drawer :model-value="modelValue" bordered show-if-above @update:model-value="$emit('update:modelValue', $event)">
    <q-scroll-area class="fit">
      <q-tree :nodes="navCollection" node-key="label" children-key="items" default-expand-all class="q-pa-sm">
        <template #default-header="{ node }">
          <!-- 有連結：可點擊的頁面節點 -->
          <q-item v-if="node.url" clickable dense :to="node.url" class="full-width">
            <q-item-section v-if="node.icon" avatar>
              <q-icon :name="node.icon" size="sm" />
            </q-item-section>

            <q-item-section>
              <q-item-label>
                {{ node.label }}
              </q-item-label>
            </q-item-section>
          </q-item>

          <!-- 無連結：分類群組節點 -->
          <div v-else class="row items-center q-gutter-sm">
            <q-icon v-if="node.icon" :name="node.icon" size="sm" color="primary" />

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
  import navCollection from '@/service/nav-collection.js'

  defineProps(['modelValue'])
  defineEmits(['update:modelValue'])
</script>
