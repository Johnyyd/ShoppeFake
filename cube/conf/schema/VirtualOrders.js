cube(`VirtualOrders`, {
  sql: `SELECT * FROM ShoppeDB.dbo.Virtual_Orders`,

  preAggregations: {
    main: {
      measures: [
        CUBE.count,
        CUBE.totalVirtualCurrencySpent,
        CUBE.totalDopamineHits
      ],
      dimensions: [CUBE.createdAt.day],
      timeDimension: CUBE.createdAt,
      granularity: `day`
    }
  },

  measures: {
    count: {
      type: `count`,
      title: `Total Virtual Orders`
    },

    totalVirtualCurrencySpent: {
      sql: `virtual_price_paid`,
      type: `sum`,
      title: `Total Virtual Currency Spent`
    },

    totalDopamineHits: {
      sql: `dopamine_hits_awarded`,
      type: `sum`,
      title: `Total Dopamine Hits Awarded`
    },

    avgVirtualOrderValue: {
      sql: `virtual_price_paid`,
      type: `avg`,
      title: `Average Order Value (Virtual)`
    }
  },

  dimensions: {
    id: {
      sql: `id`,
      type: `number`,
      primaryKey: true
    },

    userId: {
      sql: `user_id`,
      type: `number`
    },

    productId: {
      sql: `product_id`,
      type: `number`
    },

    createdAt: {
      sql: `created_at`,
      type: `time`
    }
  }
});
