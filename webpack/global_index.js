import React from 'react';
import { translate as __ } from 'foremanReact/common/I18n';
import { registerColumns } from 'foremanReact/components/HostsIndex/Columns/core';
import { DEFAULT_USER_COLUMNS } from 'foremanReact/components/PF4/TableIndexPage/Table/helpers';
import { addGlobalFill } from 'foremanReact/components/common/Fill/GlobalFill';
import { onColumnsReady } from './src/config';
import ColumnValue from './src/ColumnValue';
import CustomPropertiesCard from './src/CustomPropertiesCard';

const CARD_KEY = '[foreman_column_view] Custom properties';
// Between the core "System properties" (4000) and "Operating systems" (3000) cards
const CARD_WEIGHT = 3500;

const byPosition = (a, b) =>
  (a.after ?? Infinity) - (b.after ?? Infinity) || a.name.localeCompare(b.name);

onColumnsReady(columns => {
  const listColumns = columns.filter(column => column.view === 'hosts_list');
  const propertiesColumns = columns
    .filter(column => column.view === 'hosts_properties')
    .sort(byPosition);

  registerColumns(
    listColumns.map(column => ({
      columnName: column.key,
      title: column.title,
      wrapper: hostDetails => (
        <ColumnValue column={column} hostDetails={hostDetails} />
      ),
      weight: column.weight,
      tableName: 'hosts',
      categoryName: __('Custom columns'),
      categoryKey: 'column_view',
      isSorted: false,
    }))
  );

  // Show the columns to users who never customised the table, as the legacy page does
  listColumns.forEach(column => {
    if (!DEFAULT_USER_COLUMNS.includes(column.key)) {
      DEFAULT_USER_COLUMNS.push(column.key);
    }
  });

  if (propertiesColumns.length > 0) {
    addGlobalFill(
      'host-tab-details-cards',
      CARD_KEY,
      <CustomPropertiesCard key={CARD_KEY} columns={propertiesColumns} />,
      CARD_WEIGHT
    );
  }
});
