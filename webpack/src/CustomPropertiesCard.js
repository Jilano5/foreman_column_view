import React from 'react';
import PropTypes from 'prop-types';
import {
  DescriptionList,
  DescriptionListTerm,
  DescriptionListGroup,
  DescriptionListDescription,
} from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import CardTemplate from 'foremanReact/components/HostDetails/Templates/CardItem/CardTemplate';
import ColumnValue from './ColumnValue';

// Rows configured with `:view: :hosts_properties`, shown on the host details page
const CustomPropertiesCard = ({ hostDetails, columns }) => {
  const values = hostDetails?.column_view || {};
  const rows = columns.filter(
    column => values[column.name] !== undefined && values[column.name] !== null
  );
  if (rows.length === 0) return null;

  return (
    <CardTemplate header={__('Custom properties')} expandable masonryLayout>
      <DescriptionList isCompact isHorizontal>
        {rows.map(column => (
          <DescriptionListGroup key={column.key}>
            <DescriptionListTerm>{column.title}</DescriptionListTerm>
            <DescriptionListDescription>
              <ColumnValue column={column} hostDetails={hostDetails} />
            </DescriptionListDescription>
          </DescriptionListGroup>
        ))}
      </DescriptionList>
    </CardTemplate>
  );
};

CustomPropertiesCard.propTypes = {
  hostDetails: PropTypes.object,
  columns: PropTypes.arrayOf(PropTypes.object).isRequired,
};

CustomPropertiesCard.defaultProps = {
  hostDetails: {},
};

export default CustomPropertiesCard;
