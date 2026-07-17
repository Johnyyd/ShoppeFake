cube(`DopamineHits`, {
  sql: `
    SELECT 
      vo.id as order_id,
      vo.user_id,
      vo.product_id,
      vp.name as product_name,
      vp.category as product_category,
      vo.dopamine_hits_awarded,
      vo.created_at
    FROM ShoppeDB.dbo.Virtual_Orders vo
    JOIN ShoppeDB.dbo.Virtual_Products vp ON vo.product_id = vp.id
  `,

  measures: {
    totalHitsGenerated: {
      sql: `dopamine_hits_awarded`,
      type: `sum`,
      title: `Dopamine Hits Generated`
    },

    maxSingleHit: {
      sql: `dopamine_hits_awarded`,
      type: `max`,
      title: `Highest Single Dopamine Burst`
    }
  },

  dimensions: {
    orderId: {
      sql: `order_id`,
      type: `number`,
      primaryKey: true
    },

    userId: {
      sql: `user_id`,
      type: `number`
    },

    productName: {
      sql: `product_name`,
      type: `string`
    },

    productCategory: {
      sql: `product_category`,
      type: `string`
    },

    createdAt: {
      sql: `created_at`,
      type: `time`
    }
  }
});
