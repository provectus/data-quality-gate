from typing import Any, Optional

import pandas as pd
from pandas_profiling.expectations_report import ExpectationHandler
from visions import VisionsTypeset

from pandas_profiling.config import Settings
from pandas_profiling.model import expectation_algorithms
from pandas_profiling.model.handler import Handler
from pandas_profiling.utils.dataframe import slugify
import re
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
        mapping_schema: Optional[list] = None,
        save_suite: bool = True,
        reuse_suite: bool = False,
        run_validation: bool = True,
        build_data_docs: bool = True,
        old_suite_name: Optional[str] = None,
        use_old_suite: Optional[str] = None,
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

        new_column_in_mapping = {}
        if reuse_suite:
            if use_old_suite:
                suite_old = data_context.get_expectation_suite(old_suite_name)
                data_context.save_expectation_suite(expectation_suite=suite_old,expectation_suite_name=suite_name,overwrite_existing=True)
            else:
                suite_old = data_context.get_expectation_suite(old_suite_name)
                schema_list = list(mapping_schema.keys())
                schema_list.append('_nocolumn')

                r = re.compile("new_col_added")
                new_column_in_mapping_keys = list(filter(r.match, schema_list))
                for key in new_column_in_mapping_keys:
                    new_column_in_mapping.update({key:mapping_schema[key]})
                if new_column_in_mapping_keys:
                    schema_list = [x for x in schema_list if x not in new_column_in_mapping_keys]
                old_schema_list = list(suite_old.get_grouped_and_ordered_expectations_by_column()[0].keys())
                new_schema_list = [x for x in old_schema_list if x not in schema_list]
                for key in new_schema_list:
                    exp_conf = []
                    exp_conf.append(suite_old.get_grouped_and_ordered_expectations_by_column()[0][key])
                    for exps in exp_conf:
                        for exp in exps:
                            suite_old.remove_expectation(
                                exp,
                                match_type="runtime",
                                )
                schema_values = list(mapping_schema.values())
                for key,v in zip(schema_list,schema_values):
                    exp_conf = []
                    exp_conf.append(suite_old.get_grouped_and_ordered_expectations_by_column()[0][key])
                    for exps in exp_conf:
                        for exp in exps:
                            if(exp['expectation_type']=='expect_table_columns_to_match_set'):
                                suite_old.patch_expectation(
                                    exp,
                                    op="replace",
                                    path="/column_set",
                                    value=schema_values,
                                    match_type="runtime",
                                )
                            elif (exp['expectation_type']!='expect_table_row_count_to_equal'):
                                suite_old.patch_expectation(
                                    exp,
                                    op="replace",
                                    path="/column",
                                    value=v,
                                    match_type="runtime",
                                )
                data_context.save_expectation_suite(expectation_suite=suite_old,expectation_suite_name=suite_name,overwrite_existing=True)


                if new_column_in_mapping:
                    suite = data_context.get_expectation_suite(suite_name)
                    batch = ge.dataset.PandasDataset(self.df, expectation_suite=suite)
                    summary = self.get_description()
                    for name, variable_summary in summary["variables"].items():
                        if name in list(new_column_in_mapping.values()):
                            handler.handle(variable_summary["type"], name, variable_summary, batch)
                    suite = batch.get_expectation_suite(discard_failed_expectations=False)
                    data_context.save_expectation_suite(suite,overwrite_existing=True)

        else:
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
                if mapping_schema is not None:
                    if name in list(mapping_schema.keys()):
                        handler.handle(variable_summary["type"], name, variable_summary, batch)
                else:
                    handler.handle(variable_summary["type"], name, variable_summary, batch)
            batch.expect_table_columns_to_match_set(
                column_set=name_list)
            # batch.expect_table_row_count_to_equal(value=summary['table']['n'])
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
            if save_suite or build_data_docs:
                data_context.save_expectation_suite(suite)

            if build_data_docs:
                data_context.build_data_docs()
                data_context.open_data_docs(validation_result_identifier)

            return batch.get_expectation_suite()