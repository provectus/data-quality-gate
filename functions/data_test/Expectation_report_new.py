import itertools
from typing import Any, Optional

import pandas as pd
from great_expectations.core import ExpectationConfiguration
from ydata_profiling.expectations_report import ExpectationHandler
from visions import VisionsTypeset

from ydata_profiling.config import Settings
from ydata_profiling.model.handler import Handler
import re


class ExpectationsReportNew:
    config: Settings
    df: Optional[pd.DataFrame] = None

    @property
    def typeset(self) -> Optional[VisionsTypeset]:
        return None

    def to_expectation_suite(
        self,
        run_name: Optional[str] = None,
        suite_name: Optional[str] = None,
        data_context: Optional[Any] = None,
        mapping_config: Optional[dict] = None,
        save_suite: bool = True,
        reuse_suite: bool = False,
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

        ignored_columns = []
        try:
            import great_expectations as ge
        except ImportError:
            raise ImportError(
                "Please install great expectations before using the expectation functionality"
            )

        # Use the default handler if none
        if handler is None:
            handler = ExpectationHandler(self.typeset)

        # Obtain the ge context and create the expectation suite
        if not data_context:
            data_context = ge.data_context.DataContext()

        new_column_in_mapping = {}
        try:
            mapping_schema = mapping_config[suite_name]
        except KeyError:
            mapping_schema = None

        data_asset = data_context.get_datasource("cloud").get_asset(f"{suite_name}_{run_name}")
        batch_request = data_asset.build_batch_request()

        if reuse_suite:
            if use_old_suite:
                suite_old = data_context.get_expectation_suite(f"{suite_name}_{old_suite_name}")
                data_context.add_or_update_expectation_suite(expectation_suite=suite_old,
                                                             expectation_suite_name=f"{suite_name}_{run_name}")
            else:
                schema_list = list(mapping_schema.keys())
                dict_keys = [i for i in mapping_schema if isinstance(mapping_schema[i], dict)]

                if not dict_keys:
                    suite_old = data_context.get_expectation_suite(f"{suite_name}_{old_suite_name}")
                    schema_list.append("_nocolumn")

                    r = re.compile("new_col_added")
                    new_column_in_mapping_keys = list(filter(r.match, schema_list))
                    for key in new_column_in_mapping_keys:
                        new_column_in_mapping.update({key: mapping_schema[key]})
                    if new_column_in_mapping_keys:
                        schema_list = [x for x in schema_list if
                                       x not in new_column_in_mapping_keys and x not in ignored_columns]
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
                    for key, v in list(itertools.zip_longest(schema_list, schema_values)):
                        exp_conf = []
                        exp_conf.append(suite_old.get_grouped_and_ordered_expectations_by_column()[0][key])
                        for exps in exp_conf:
                            for exp in exps:
                                if (exp["expectation_type"] == "expect_table_columns_to_match_set"):
                                    suite_old.patch_expectation(
                                        exp,
                                        op="replace",
                                        path="/column_set",
                                        value=schema_values,
                                        match_type="runtime",
                                    )
                                elif (exp["expectation_type"] != "expect_table_row_count_to_equal"):
                                    suite_old.patch_expectation(
                                        exp,
                                        op="replace",
                                        path="/column",
                                        value=v,
                                        match_type="runtime",
                                    )
                    data_context.add_or_update_expectation_suite(expectation_suite=suite_old,
                                                                 expectation_suite_name=f"{suite_name}_{run_name}")

                    if new_column_in_mapping:
                        suite_old = data_context.get_expectation_suite(f"{suite_name}_{run_name}")
                        validator = data_context.get_validator(
                            batch_request=batch_request,
                            expectation_suite=suite_old,
                        )
                        summary = self.get_description()
                        for name, variable_summary in summary.variables.items():
                            if name in list(new_column_in_mapping.values()):
                                handler.handle(variable_summary["type"], name, variable_summary, validator)
                        suite = validator.get_expectation_suite(discard_failed_expectations=False)
                        data_context.add_or_update_expectation_suite(expectation_suite=suite,
                                                                     expectation_suite_name=f"{suite_name}_{run_name}")
                else:  # if we have nested tables
                    r = re.compile("new_col_added")
                    new_column_in_mapping_keys = list(filter(r.match, schema_list))
                    schema_list = [x for x in schema_list if x not in new_column_in_mapping_keys]
                    schema_list = [x for x in schema_list if
                                   x not in dict_keys]  # subtract original suite list keys from nested
                    dict_keys_schema_list = []
                    dict_values_schema_list = []
                    for key in dict_keys:
                        if not mapping_schema[key]:
                            dict_keys_schema_list.append(
                                list(mapping_config[key].keys()))  # create list of lists for nested suites columns
                            dict_values_schema_list.append(list(mapping_config[key].values()))
                        else:
                            dict_keys_schema_list.append(
                                list(mapping_schema[key].keys()))  # if nested table has renaming
                            dict_values_schema_list.append(list(mapping_schema[key].values()))
                    dict_suites = []
                    for d_key in dict_keys:
                        suite_old = data_context.get_expectation_suite(f"{d_key}_{old_suite_name}")
                        old_schema_list = list(suite_old.get_grouped_and_ordered_expectations_by_column()[
                                                   0].keys())  # get schema from original nested suite
                        dict_keys_schema_list[list(dict_keys).index(d_key)].append("_nocolumn")
                        new_schema_list = [x for x in old_schema_list if x not in dict_keys_schema_list[
                            list(dict_keys).index(d_key)]]  # subtract mapping schema from original schema
                        for key in new_schema_list:  # delete not necessary tests based on mapping
                            exp_conf = []
                            exp_conf.append(suite_old.get_grouped_and_ordered_expectations_by_column()[0][key])
                            for exps in exp_conf:
                                for exp in exps:
                                    suite_old.remove_expectation(
                                        exp,
                                        match_type="runtime",
                                    )

                        # schema_values = list(mapping_config[d_key].values())
                        schema_values = dict_values_schema_list[list(dict_keys).index(d_key)]
                        for key, v in zip(dict_keys_schema_list[list(dict_keys).index(d_key)],
                                          schema_values):  # remove table schema test and replace columns name in tests
                            exp_conf = []
                            if key in suite_old.get_grouped_and_ordered_expectations_by_column()[0]:
                                exp_conf.append(suite_old.get_grouped_and_ordered_expectations_by_column()[0][key])
                                for exps in exp_conf:
                                    for exp in exps:
                                        if (exp["expectation_type"] == "expect_table_columns_to_match_set" or exp[
                                            "expectation_type"] == "expect_table_row_count_to_equal"):
                                            suite_old.remove_expectation(
                                                exp,
                                                match_type="runtime",
                                            )
                                        else:
                                            suite_old.patch_expectation(
                                                exp,
                                                op="replace",
                                                path="/column",
                                                value=v,
                                                match_type="runtime",
                                        )
                        dict_suites.append(suite_old)

                    # ##run tests generation against new columns
                    suite_old = data_context.add_or_update_expectation_suite(
                        expectation_suite_name=f"{suite_name}_{run_name}"
                    )
                    validator = data_context.get_validator(
                        batch_request=batch_request,
                        expectation_suite=suite_old,
                    )
                    summary = self.get_description()
                    for name, variable_summary in summary.variables.items():
                        if name in schema_list and name not in ignored_columns:
                            handler.handle(variable_summary["type"], name, variable_summary, validator)
                    suite = validator.get_expectation_suite(discard_failed_expectations=False)

                    ## join all suites to one
                    ## new version
                    # for dict_suite in dict_suites:
                    #     for (key, value) in dict_suite.get_grouped_and_ordered_expectations_by_column()[0].items():
                    #         suite.add_expectation_configurations(value)

                    for dict_suite in dict_suites:
                        for (key, values) in dict_suite.get_grouped_and_ordered_expectations_by_column()[0].items():
                            for value in values:
                                suite.add_expectation(ExpectationConfiguration(kwargs=value["kwargs"],
                                                                               expectation_type=value[
                                                                                   "expectation_type"],
                                                                               meta=value["meta"]))

                    ##  add expected_table_columns_to_match_set
                    final_schema = sum(dict_values_schema_list, [mapping_schema[x] for x in schema_list])

                    suite.add_expectation(
                        expectation_configuration=ExpectationConfiguration(kwargs={"column_set": final_schema},
                                                                           expectation_type="expect_table_columns_to_match_set"))
                    suite.add_expectation(
                        expectation_configuration=ExpectationConfiguration(kwargs={"value": summary.table['n']},
                                                                           expectation_type="expect_table_row_count_to_equal"))
                    data_context.add_or_update_expectation_suite(expectation_suite=suite,
                                                                 expectation_suite_name=f"{suite_name}_{run_name}")
        else:

            suite = data_context.add_or_update_expectation_suite(
                expectation_suite_name=f"{suite_name}_{run_name}"
            )

            # Instantiate an in-memory pandas dataset
            validator = data_context.get_validator(
                batch_request=batch_request,
                expectation_suite=suite,
            )
            # Obtain the profiling summary
            summary = self.get_description()  # type: ignore

            # Dispatch to expectations per semantic variable type
            name_list = []
            for name, variable_summary in summary.variables.items():
                name_list.append(name)
                if mapping_schema is not None:
                    if name in list(mapping_schema.keys()) and name not in ignored_columns:
                        handler.handle(variable_summary["type"], name, variable_summary, validator)
                else:
                    if name not in ignored_columns:
                        handler.handle(variable_summary["type"], name, variable_summary, validator)
            validator.expect_table_columns_to_match_set(
                column_set=name_list)
            validator.expect_table_row_count_to_equal(value=summary.table['n'])
            suite = validator.get_expectation_suite(discard_failed_expectations=False)

            if save_suite:
                data_context.update_expectation_suite(suite)

            return validator.get_expectation_suite()
