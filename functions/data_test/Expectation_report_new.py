from typing import Any, Optional

import pandas as pd
from pandas_profiling.expectations_report import ExpectationHandler
from visions import VisionsTypeset

from pandas_profiling.config import Settings
from pandas_profiling.model import expectation_algorithms
from pandas_profiling.model.handler import Handler
from pandas_profiling.utils.dataframe import slugify

class ExpectationsReportNew:
    config: Settings
    df: Optional[pd.DataFrame] = None

    @property
    def typeset(self) -> Optional[VisionsTypeset]:
        return None

    def to_expectation_suite(
        self,
        suite_name: Optional[str] = None,
        data_context: Optional[Any] = None,
        save_suite: bool = True,
        run_validation: bool = True,
        build_data_docs: bool = True,
        handler: Optional[Handler] = None,
    ) -> Any:
        """
        All parameters default to True to make it easier to access the full functionality of Great Expectations out of
        the box.
        Args:
            suite_name: The name of your expectation suite
            data_context: A user-specified data context
            save_suite: Boolean to determine whether to save the suite to .json as part of the method
            run_validation: Boolean to determine whether to run validation as part of the method
            build_data_docs: Boolean to determine whether to build data docs, save the .html file, and open data docs in
                your browser
            handler: The handler to use for building expectation

        Returns:
            An ExpectationSuite
        """
        try:
            import great_expectations as ge
        except ImportError:
            raise ImportError(
                "Please install great expectations before using the expectation functionality"
            )

        # Use report title if suite is empty
        if suite_name is None:
            suite_name = slugify(self.config.title)

        # Use the default handler if none
        if handler is None:
            handler = ExpectationHandler(self.typeset)

        # Obtain the ge context and create the expectation suite
        if not data_context:
            data_context = ge.data_context.DataContext()

        suite = data_context.create_expectation_suite(
            suite_name, overwrite_existing=True,
        )

        # Instantiate an in-memory pandas dataset
        batch = ge.dataset.PandasDataset(self.df, expectation_suite=suite)


        # Obtain the profiling summary
        summary = self.get_description()  # type: ignore

        # Dispatch to expectations per semantic variable type
        name_list = []
        for name, variable_summary in summary["variables"].items():
            name_list.append(name)
            handler.handle(variable_summary["type"], name, variable_summary, batch)
        batch.expect_table_columns_to_match_ordered_list(
            column_list=name_list)
        batch.expect_table_row_count_to_equal(value=summary['table']['n'])
                # We don't actually update the suite object on the batch in place, so need
        # to get the populated suite from the batch
        suite = batch.get_expectation_suite(discard_failed_expectations=False)

        validation_result_identifier = None
        if run_validation:
            batch = ge.dataset.PandasDataset(self.df, expectation_suite=suite)

            results = data_context.run_validation_operator(
                "action_list_operator", assets_to_validate=[batch]
            )
            validation_result_identifier = results.list_validation_result_identifiers()[
                0
            ]
        # Write expectations and open data docs
        if save_suite or build_data_docs:
            data_context.save_expectation_suite(suite)

        if build_data_docs:
            data_context.build_data_docs()
            data_context.open_data_docs(validation_result_identifier)

        return batch.get_expectation_suite()