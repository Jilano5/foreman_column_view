import React from 'react';
import PropTypes from 'prop-types';

// Evaluated content (:eval_content) is HTML escaped by the server,
// everything else is displayed as text
const ColumnValue = ({ column, hostDetails }) => {
  const value = hostDetails?.column_view?.[column.name];
  if (value === undefined || value === null) return null;
  if (column.html) {
    // eslint-disable-next-line react/no-danger
    return <span dangerouslySetInnerHTML={{ __html: value }} />;
  }
  return <span>{String(value)}</span>;
};

ColumnValue.propTypes = {
  column: PropTypes.shape({
    name: PropTypes.string.isRequired,
    html: PropTypes.bool,
  }).isRequired,
  hostDetails: PropTypes.object,
};

ColumnValue.defaultProps = {
  hostDetails: {},
};

export default ColumnValue;
